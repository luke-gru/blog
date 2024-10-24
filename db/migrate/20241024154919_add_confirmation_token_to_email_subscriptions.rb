class AddConfirmationTokenToEmailSubscriptions < ActiveRecord::Migration[7.2]
  def change
    add_column :email_subscriptions, :confirmation_token, :text
    add_column :email_subscriptions, :confirmed_at, :datetime
    add_index :email_subscriptions, :confirmed_at
    add_index :email_subscriptions, :confirmation_token
  end
end
