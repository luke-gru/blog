module PostHelper
  # @param post Post
  def post_title(post)
    case I18n.locale
    when :en
      post.title
    when :fr
      post.title_fr.presence || post.title
    end.to_s
  end

  # @param post Post
  def post_erb_content(post)
    case I18n.locale
    when :en
      post.erb_content
    when :fr
      if post.content_fr_processed.present?
        post.erb_content(content: post.content_fr_processed)
      else
        post.erb_content
      end
    end.to_s
  end

  def post_meta_description(post)
    case I18n.locale
    when :en
      post.meta_description
    when :fr
    post.meta_description_fr.presence || post.meta_description
    end.to_s
  end

  # @param tag Tag
  def tag_name(tag)
    case I18n.locale
    when :en
      tag.tag
    when :fr
      tag.tag_fr.presence || tag.tag
    end.to_s
  end

end
