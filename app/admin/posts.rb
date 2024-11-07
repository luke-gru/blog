# frozen_string_literal: true
ActiveAdmin.register Post do
  menu priority: 10

  filter :user
  filter :title
  filter :created_at

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

  show do
    attributes_table_for(resource) do
      row :user do |p|
        p.user.display_name
      end
      row "Title (EN)" do |p|
        p.title
      end
      row "Title (FR)" do |p|
        p.title_fr
      end
      row "Slug" do |p|
        div { "Current:<br>&nbsp#{p.slug}".html_safe }
        if p.slug.present? && (slugs = p.slugs).size > 1
          div { "Others:" }
          slugs.each do |slug|
            div { "&nbsp".html_safe + slug.slug } unless slug.slug == p.slug
          end
          nil
        end
      end
      row :status
      row :first_published_at
      row "Content (EN)" do |p|
        post_content_code_block(self, p)
      end
      row "Content (FR)" do |p|
        post_content_code_block(self, p, lang: "fr")
      end
      row "Link to page" do |p|
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
        content
      end
      row "Comments (#{resource.comments.count})" do |p|
        link_to "Show all", admin_post_comments_path(commit: "Filter", q: { post_id_eq: p.id }, order: "id_desc")
      end
    end

  end

  form partial: 'form'

  controller do
    helper "active_admin/view"
    before_action :set_content, only: [:update]

    def permitted_params
      params.permit(:utf8, :_method, :authenticity_token, :commit, :id, :locale,
        post: [
          :user_id, :title, :title_fr, :content, :content_fr_duplicate, :content_fr, :status, :images, :tag_ids => [],
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
        redirect_back(fallback_location: admin_post_path(id: params[:id]))
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
