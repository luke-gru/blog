ActiveAdmin.register Post do
  permit_params :user_id, :title, :content

  index do
    selectable_column
    id_column
    column :id
    column :user
    column :title
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
      row :content do |p|
        p.content
      end
      row :link do |p|
        link_to p.title, post_page_path(p)
      end
    end
  end

  form partial: 'form'

  controller do
    before_action :set_content, only: [:update]

    protected
    def set_content
      raw_content = params[:post][:content] || ''
      # ex: ```ruby\nputs "HI"```
      if m = raw_content.match(/```(\w+)\s*(.+)```/m)
        lang, code_content = m.captures
        code_content.gsub! /<br>/, '' # trix did this
        if lang == "ruby"
          beg_match, end_match = m.offset(0)
          before_content, after_content = [raw_content[0...beg_match], raw_content[end_match..-1]]
          html_formatter = Rouge::Formatters::HTML.new
          formatter = Rouge::Formatters::HTMLPygments.new(html_formatter, css_class='codehilite')
          lexer = Rouge::Lexers::Ruby.new
          code_content = formatter.format(lexer.lex(code_content))

          new_content = before_content + code_content + after_content
          nl_without_cr = /(?<!\r)\n/
          new_content.gsub!(nl_without_cr, "\r\n")
          params[:post][:content] = new_content
        end
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
