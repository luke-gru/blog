class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images # activestorage
  validates :user, presence: true
  validates :title, presence: true, uniqueness: true
  validates :content, presence: true
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  enum :status, [:draft, :published, :unpublished]

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

  def self.ransackable_attributes(*)
    ["content", "created_at", "id", "title", "updated_at", "user_id"]
  end

  def self.published
    where(status: [:published])
  end

  def self.recently_published(search: nil, tag: nil, most_recent: 3)
    scope = Post.published.includes(:user, :tags)
    if search.present?
      scope.where!("#{table_name}.title LIKE ? OR #{table_name}.content LIKE ?", "%#{search}%", "%#{search}%")
    end
    if tag.present?
      scope.where!(tags: { tag: tag })
    end
    scope.order("#{table_name}.created_at DESC").limit(most_recent)
  end

  def content_with_wrapper
    %Q(<div id="post-content-wrapper">#{self.content}</div>)
  end

  # TODO: what if malformatted?
  # @return String
  def indented_content(newline: "\n")
    html = content_with_wrapper
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

  def erb_content
    template = Erubis::Eruby.new(self.content, pattern: "{% %}")
    context = MyErbContext.new(post: self)
    template.evaluate(context)
  end
end
