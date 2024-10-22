ActiveAdmin.register Tag do
  permit_params :tag

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
end
