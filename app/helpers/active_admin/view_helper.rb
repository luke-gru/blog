module ActiveAdmin::ViewHelper

  def post_content_code_block(context, post, lang: "en")
    content = lang == "fr" ? post.content_fr : post.content
    context.instance_exec do
      pre do
        content
      end
    end
  end

end
