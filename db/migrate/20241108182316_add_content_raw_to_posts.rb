class AddContentRawToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :content_processed, :text
    add_column :posts, :content_fr_processed, :text
  end
end
