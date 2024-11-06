class CreatePostComments < ActiveRecord::Migration[7.2]
  def change
    create_table :post_comments do |t|
      t.belongs_to :post
      t.text :comment, null: false
      t.string :username, null: false
      t.string :ip_address, null: false
      t.integer :status, null: false, default: 0
      t.string :locale, null: false
      t.timestamps

      t.index :status
      t.index :ip_address
    end
  end
end
