class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images # activestorage
  validates :user, presence: true
  validates :title, presence: true
  validates :content, presence: true

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

  # TODO: belongs in view helper
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
    content = self.content
    template = Erubis::Eruby.new(content, pattern: "{% %}")
    context = Erubis::Context.new
    context[:post] = self
    def context.post
      @post
    end
    context.extend Rails.application.routes.url_helpers
    context.extend ActionView::RoutingUrlFor
    def context.routes
      Rails.application.routes
    end
    def context.controller
      nil
    end
    def context.default_url_options
      { only_path: true }
    end
    
    template.evaluate(context)
  end
end
