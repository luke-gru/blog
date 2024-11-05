module PostHelper
  def post_title(post)
    case I18n.locale
    when :en
      post.title
    when :fr
      post.title_fr.presence || post.title
    end
  end

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
end
