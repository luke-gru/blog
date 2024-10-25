# frozen_string_literal: true
ActiveAdmin.register Tag do
  menu priority: 30

  show do
    attributes_table_for(resource) do
      row :tag
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
          :tag,
        ]
      )
    end
  end
end
