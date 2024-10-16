class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.references :user
      t.text :title
      t.text :content
      t.timestamps
    end
  end
end
