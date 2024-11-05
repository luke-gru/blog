# frozen_string_literal: true
class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images # activestorage
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  validates :user, presence: true
  validates :title, presence: true, uniqueness: true
  validates :content, presence: true

  enum :status, [:draft, :published, :unpublished]

  # url slugs
  extend FriendlyId
  # This is created by friendly_id history module:
  # has_many :slugs, class_name: "FriendlyId::Slug", inverse_of: :sluggable
  friendly_id :title, use: [:slugged, :history]

  accepts_nested_attributes_for :post_tags # Allow Post#tag_ids = [1,3]

  attr_accessor :first_published_now
  attr_accessor :content_fr_duplicate # for active admin form

  before_save :set_first_published_at, if: (lambda do
    before_published_at = changes["first_published_at"]
    self.first_published_at.blank? && before_published_at.blank? && self.status.to_s == "published"
  end)

  before_save :set_content_fr_defaults, if: (lambda do
    self.content_fr_duplicate && self.content_fr.blank?
  end)

  after_save_commit :send_emails_to_subscribers, :if => (lambda do
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
  def erb_content(content: self.content)
    template = Erubis::Eruby.new(content, pattern: "{% %}")
    context = MyErbContext.new(post: self)
    template.evaluate(context)
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

  def set_content_fr_defaults
    self.content_fr = self.content
  end

  # callback
  def send_emails_to_subscribers
    NewPostEmailSubscribersJob.perform_later self.id
  end
end
