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
      row "Meta Description" do |p|
        p.meta_description.to_s
      end
      row "Meta Description (FR)" do |p|
        p.meta_description_fr.to_s
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

    def permitted_params
      params.permit(:utf8, :_method, :authenticity_token, :commit, :id, :locale,
        post: [
          :user_id, :title, :title_fr, :content, :content_fr, :content_fr_duplicate,
          :meta_description, :meta_description_fr, :status, :images, :tag_ids => [],
        ]
      )
    end
  end

end
