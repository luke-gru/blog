class AddFirstPublishedAtToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :first_published_at, :datetime
  end
end
