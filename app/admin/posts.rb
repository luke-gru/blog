ActiveAdmin.register Post do
  permit_params :user_id, :title, :content, :status, :images

  index do
    selectable_column
    id_column
    column :id
    column :user
    column :title
    column :status
    column :created_at
    column :updated_at
    actions
  end

  filter :user
  filter :title
  filter :created_at

  show do
    attributes_table_for(resource) do
      row :user do |p|
        p.user.display_name
      end
      row :title
      row :status
      row :content do |post|
        content = "".html_safe
        code do
          post.indented_content.lines.each do |line|
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
      row :link do |p|
        link_to p.title, post_page_path(p), target: "_blank"
      end
      row "Images (#{post.images.size})" do |p|
        content = "".html_safe
        if p.images.any?
          p.images.attachments.each do |attach|
            content << div(class: "post-image-attachment") do
              img(src: url_for(attach), style: "max-width: 250px; max-height: 250px")
            end.html_safe
          end
        else
          content << "None"
        end
      end
      content
    end
  end

  form partial: 'form'

  controller do
    before_action :set_content, only: [:update]

    protected
    def set_content
      raw_content = params[:post][:content] || ''
      # ex: replace ```ruby\nputs "HI"``` with proper pygment HTML tags
      if m = raw_content.match(/```(\w+)\s*(.+)```/m)
        lang, code_content = m.captures
        code_content.gsub! /<br>/, '' # trix used to add this, not sure if needed now
        case lang
        when "ruby"
          lexer = Rouge::Lexers::Ruby.new
        when "c"
          lexer = Rouge::Lexers::C.new
        when "js", "javascript"
          lexer = Rouge::Lexers::Javascript.new
        when "html"
          lexer = Rouge::Lexers::HTML.new
        when "css"
          lexer = Rouge::Lexers::CSS.new
        else
          flash[:error] = "Unable to parse language '#{lang}'"
          redirect_back(fallback_location: admin_post_path(id: params[:id])) and return
        end
        beg_match, end_match = m.offset(0)
        before_content, after_content = [raw_content[0...beg_match], raw_content[end_match..-1]]
        html_formatter = Rouge::Formatters::HTML.new
        formatter = Rouge::Formatters::HTMLPygments.new(html_formatter)
        code_content = formatter.format(lexer.lex(code_content))

        new_content = before_content + code_content + after_content
        nl_without_cr = /(?<!\r)\n/
        new_content.gsub!(nl_without_cr, "\r\n")
        params[:post][:content] = new_content
      end
    end
  end

  # TODO: get preview working
  # JSON request
  # /admin/posts/:id/preview_content
  member_action :preview_content do
    post = Post.find_by_id(params[:id])
    unless post
      render json: { 
        error: "Post not found"
      }, status: 404
      return
    end
    render :json => {
      html: render_to_string(partial: "/posts/post", locals: { post: post }, layout: false)
    }
  end
end
