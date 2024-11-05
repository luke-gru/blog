# frozen_string_literal: true
ActiveAdmin.register Tag do
  menu priority: 30

  index do
    selectable_column
    id_column
    column "Tag (EN)" do |t|
      t.tag
    end
    column "Tag (FR)" do |t|
    t.tag_fr
    end
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table_for(resource) do
      row "Tag (EN)" do |t|
        t.tag
      end
      row "Tag (FR)" do |t|
        t.tag_fr
      end
      row :posts do |tag|
        content = "".html_safe
        posts = tag.posts
        posts.each_with_index do |post, i|
          content << link_to(post.title, admin_post_path(post))
          content << br.html_safe unless posts[i+1].nil?
        end
        content
      end
      row :created_at
      row :updated_at
    end
  end

  controller do
    protected

    def permitted_params
      params.permit(:utf8, :_method, :authenticity_token, :commit, :id, :locale,
        tag: [
          :tag, :tag_fr
        ]
      )
    end
  end
end
