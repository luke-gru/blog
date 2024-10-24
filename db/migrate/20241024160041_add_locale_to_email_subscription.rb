class AddLocaleToEmailSubscription < ActiveRecord::Migration[7.2]
  def change
    add_column :email_subscriptions, :locale, :string
  end
end
