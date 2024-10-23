class CreateEmailSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :email_subscriptions do |t|
      t.text :email, null: false
      t.text :unsubscribe_token, null: false
      t.boolean :unsubscribed, null: false, default: false
      t.text :unsubscribe_reason
      t.datetime :last_subscribe_action, null: true
      t.datetime :last_unsubscribe_action, null: true

      t.timestamps

      t.index :email
      t.index :unsubscribe_token
    end
  end
end
