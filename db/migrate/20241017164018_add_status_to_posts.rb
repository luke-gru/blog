class AddStatusToPosts < ActiveRecord::Migration[7.2]
  def change
    change_table :posts do |t|
      t.integer :status, null: false, default: 0
    end
  end
end
