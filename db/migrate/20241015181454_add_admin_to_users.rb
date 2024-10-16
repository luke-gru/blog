class AddAdminToUsers < ActiveRecord::Migration[7.2]
  def change
    change_table :users do |t|
      t.boolean :admin, :default => false
    end
  end
end
