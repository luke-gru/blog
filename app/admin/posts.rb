# frozen_string_literal: true
ActiveAdmin.register Post do
  menu priority: 10
  # TODO: don't send locale on admin pages
  permit_params :user_id, :title, :content, :status, :images, :tag_ids => []

  index do
    selectable_column
    id_column
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
      row :first_published_at
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
      row :tags do |p|
        content = "".html_safe
        tags = p.tags
        tags.each_with_index do |tag, i|
          content << link_to(tag.tag, admin_tag_path(tag))
          content << br.html_safe unless tags[i+1].nil?
        end
        content
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
    before_action :remove_locale_if_set, only: [:update, :create]

    def permitted_params
      params.permit(:utf8, :_method, :authenticity_token, :commit, :id, :locale,
        post: [
          :user_id, :title, :content, :status, :images, :tag_ids => [],
        ]
      )
    end

    private

    def set_content
      raw_content = params[:post][:content] || ''
      highlight = CodeHighlighting.new(raw_content)
      if (new_content = highlight.substitute_code_templates)
        params[:post][:content] = new_content
      elsif highlight.error
        flash[:error] = highlight.error
        redirect_back(fallback_location: admin_post_path(id: params[:id])) and return
      end
    end

    def remove_locale_if_set
      if params[:locale]
        params.delete(:locale)
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
