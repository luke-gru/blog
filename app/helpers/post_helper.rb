module PostHelper
  # @param post Post
  def post_title(post)
    case I18n.locale
    when :en
      post.title
    when :fr
      post.title_fr.presence || post.title
    end
  end

  # @param post Post
  def post_erb_content(post)
    case I18n.locale
    when :en
      post.erb_content
    when :fr
      if post.content_fr.present?
        post.erb_content(content: post.content_fr)
      else
        post.erb_content
      end
    end
  end

  # @param tag Tag
  def tag_name(tag)
    case I18n.locale
    when :en
      tag.tag
    when :fr
      tag.tag_fr.presence || tag.tag
    end
  end
end
