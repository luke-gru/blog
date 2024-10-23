class EmailSubscription < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :unsubscribe_token, presence: true
  validates :unsubscribed, inclusion: [true, false]

  has_secure_token :unsubscribe_token, length: 50

  before_validation :set_defaults, on: :create

  def self.can_email
    where(unsubscribed: false)
  end

  def still_subscribed?
    not unsubscribed?
  end

  private

  def set_defaults
    self.unsubscribed ||= false
  end

end
