# frozen_string_literal: true
ActiveAdmin.register PostComment do
  menu priority: 15
  actions :all, except: [:new, :create, :destroy]

  filter :post
  filter :username
  filter :status, as: :select, collection: PostComment.pretty_statuses.to_a
  filter :ip_address

  index do
    selectable_column
    id_column
    column "Post" do |c|
      if c.post
        link_to c.post.title, admin_post_path(c.post)
      else
        "-"
      end
    end
    column :username
    column "Status" do |c|
      c.pretty_status
    end
    column :ip_address
    column :created_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :post, include_blank: false, input_html: { disabled: true }
      f.input :comment, input_html: { readonly: true }
      f.input :username, input_html: { readonly: true }
      f.input :ip_address, input_html: { readonly: true }
      f.input :status, include_blank: false
      f.input :locale, input_html: { readonly: true }
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit(:utf8, :_method, :authenticity_token, :commit, :id, :locale,
        post_comment: [
          :status, :comment, :username, :ip_address, :locale
        ]
      )
    end
  end
end
