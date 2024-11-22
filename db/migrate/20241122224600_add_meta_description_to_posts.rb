class AddMetaDescriptionToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :meta_description, :text
    add_column :posts, :meta_description_fr, :text
  end
end
