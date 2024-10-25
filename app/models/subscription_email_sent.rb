# frozen_string_literal: true
class SubscriptionEmailSent < ApplicationRecord
  self.table_name = "subscription_emails_sent"

  belongs_to :post
  belongs_to :email_subscription

  validates :to, presence: true
  validates :content, presence: true

  def self.ransackable_associations(auth_object = nil)
    ["email_subscription", "post"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["content", "created_at", "email_subscription_id", "id", "locale", "post_id", "subject", "to", "updated_at"]
  end
end
