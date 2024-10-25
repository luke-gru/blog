class CreateSubscriptionEmailsSent < ActiveRecord::Migration[7.2]
  def change
    create_table :subscription_emails_sent do |t|
      t.references :post
      t.references :email_subscription
      t.string :to, null: false
      t.text :subject
      t.text :content, null: false
      t.string :locale
      t.timestamps

      t.index :to
    end
  end
end
