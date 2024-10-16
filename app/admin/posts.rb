ActiveAdmin.register Post do
  class ::ActionText::RichText
    def self.ransackable_attributes(auth_object = nil)
      ["body", "created_at", "id", "name", "record_id", "record_type", "updated_at"]
    end
  end

  permit_params :user, :title, :content

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
        # ActionText::Content#to_html
        p.content.body.to_html
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :user
      f.input :title, as: :string
      f.input :content, as: :action_text
    end
    f.actions
  end
end
