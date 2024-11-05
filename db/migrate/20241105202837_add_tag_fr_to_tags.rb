class AddTagFrToTags < ActiveRecord::Migration[7.2]
  def change
    add_column :tags, :tag_fr, :string
  end
end
