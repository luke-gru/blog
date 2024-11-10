# frozen_string_literal: true
class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images # activestorage
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_many :comments, class_name: "PostComment"

  validates :user, presence: true
  validates :title, presence: true, uniqueness: true
  validates :content, presence: true

  enum :status, [:draft, :published, :unpublished]

  # Url slugs. They come from the title of the post.
  extend FriendlyId
  # This is created by friendly_id history module:
  # has_many :slugs, class_name: "FriendlyId::Slug", inverse_of: :sluggable
  friendly_id :title, use: [:slugged, :history]

  accepts_nested_attributes_for :post_tags # Allow Post#tag_ids = [1,3]

  attr_accessor :first_published_now
  attr_accessor :content_fr_duplicate # for active admin form
  attr_accessor :force_content_processing

  before_save(:set_first_published_at, if: lambda do
    before_published_at = changes["first_published_at"]
    self.first_published_at.blank? && before_published_at.blank? && self.status.to_s == "published"
  end)

  before_save(:set_content_fr_defaults, if: lambda do
    self.content_fr_duplicate && self.content_fr.blank?
  end)

  before_save(:sanitize_content, if: lambda do
    self.content_changed?
  end)

  before_save(:sanitize_content_fr, if: lambda do
    self.content_fr_changed?
  end)

  before_save(:process_content, if: lambda do
    self.force_content_processing || self.content_changed? ||
      (self.content_processed.blank? && self.content.present?)
  end)

  before_save(:process_content_fr, if: lambda do
    self.force_content_processing || self.content_fr_changed? ||
      (self.content_fr_processed.blank? && self.content_fr.present?)
  end)

  after_save_commit(:send_emails_to_subscribers, if: lambda do
    self.first_published_now
  end)

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

  def self.ransackable_attributes(*)
    ["content", "content_fr", "content_fr_duplicate", "created_at", "id", "title", "title_fr", "updated_at", "user_id"]
  end

  def self.published
    where(status: [:published])
  end

  def self.recently_published(search: nil, tag: nil, most_recent: 3)
    scope = Post.published.includes(:user, :tags)
    if search.present?
      locale = I18n.locale
      title_field = locale == :en ? "title" : "title_fr"
      content_field = locale == :en ? "content" : "content_fr"
      scope.where!("#{table_name}.#{title_field} LIKE ? OR #{table_name}.#{content_field} LIKE ?", "%#{search}%", "%#{search}%")
    end
    if tag.present?
      scope.where!(tags: { tag: tag })
    end
    scope.order("#{table_name}.created_at DESC").limit(most_recent)
  end

  def content_with_wrapper(lang: "en")
    content = lang == "fr" ? self.content_fr : self.content
    %Q(<div id="post-content-wrapper">#{content}</div>)
  end

  # TODO: what if malformatted?
  # @return String, properly indented HTML with newlines after each tag
  def indented_content(lang: "en", newline: "\n")
    html = content_with_wrapper(lang: lang)
    doc = Nokogiri::XML(html, &:noblanks)
    doc.css("#post-content-wrapper").children.map do |node|
      if node.node_name == "div" && node.attributes["class"]&.value == "highlight"
        # there's a <pre> block in it so we don't want to add any spaces in it
        node.to_html
      else
        node.to_s + newline
      end
    end.join
  end

  # @return String
  def erb_content(content: self.content_processed)
    if content.blank?
      content = self.content
    end
    template = Erubis::Eruby.new(content, pattern: "{% %}")
    context = MyErbContext.new(post: self)
    template.evaluate(context)
  end

  def create_or_update_slug!
    save! if should_generate_new_friendly_id?
  end

  # friendly_id hook
  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end

  private

  # callback
  def set_first_published_at
    self.first_published_at ||= Time.zone.now
    self.first_published_now = true
  end

  # callback
  def set_content_fr_defaults
    self.content_fr = self.content
  end

  # callback
  def sanitize_content
    do_sanitize_content(:content)
  end

  # callback
  def sanitize_content_fr
    do_sanitize_content(:content_fr)
  end

  # callback
  def process_content
    do_process_content(:content)
  end

  # callback
  def process_content_fr
    do_process_content(:content_fr)
  end

  def do_sanitize_content(field)
    val = send(field)
    if val.present?
      val = val.gsub(/\r\n/, "\n")
      send("#{field}=", val)
    end
  end

  def do_process_content(field)
    raw_content = send(field) || ''
    hl = CodeHighlighting.new(raw_content, input_is_html_safe: true)
    if (new_content = hl.substitute_code_templates)
      Rails.logger.info "Code highlight substitutions for Post #{self.id} (#{field}): #{hl.num_substitutions}"
      begin
        new_content = PostContentProcessing.new(new_content, strict: true).process
        send("#{field}_processed=", new_content)
      rescue PostContentProcessing::Error => e
        # don't set field
        Rails.logger.error "Error in PostContentProcessing for Post #{self.id}: #{e.message}"
      end
    # don't set field
    elsif highlight.error
      Rails.logger.error "Error highlighting code for Post #{self.id}: #{hl.error}"
    end
  end

  # callback
  def send_emails_to_subscribers
    NewPostEmailSubscribersJob.perform_later self.id
  end
end
