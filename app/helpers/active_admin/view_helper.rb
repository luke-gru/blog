module ActiveAdmin::ViewHelper

  def post_content_code_block(context, post, lang: "en")
    content = "".html_safe
    context.instance_exec do
      code do
        post.indented_content(lang: lang).lines.each do |line|
          content << para { # p tag
            p_content = "".html_safe
            parts = line.split(/( )/)
            parts.each do |part|
              if part == " "
                p_content << "&nbsp;".html_safe
              else
                p_content << part
              end
            end
            p_content
          }
        end
        content
      end
    end
  end

end
