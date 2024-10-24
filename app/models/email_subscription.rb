# frozen_string_literal: true
class EmailSubscription < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :unsubscribe_token, presence: true
  validates :confirmation_token, presence: true
  validates :unsubscribed, inclusion: [true, false]
  validates :locale, inclusion: I18n.available_locales.map(&:to_s) + ["",nil]

  has_secure_token :unsubscribe_token, length: 50
  has_secure_token :confirmation_token, length: 50

  before_validation :set_defaults, on: :create

  def self.can_email
    confirmed.still_subscribed
  end

  def self.still_subscribed
    where(email_subscriptions: { unsubscribed: false })
  end

  def self.confirmed
    where.not(email_subscriptions: { confirmed_at: nil })
  end

  def unsubscribe!
    update!(
      last_subscribe_action: Time.zone.now,
      unsubscribed: true,
    )
  end

  def resubscribe!
    update!(
      unsubscribed: false,
      last_subscribe_action: Time.zone.now,
      confirmed_at: nil,
    )
  end

  def confirm!
    update!(
      confirmed_at: Time.zone.now,
      unsubscribed: false,
    )
  end

  def still_subscribed?
    not unsubscribed?
  end

  def confirmed?
    confirmed_at.present?
  end

  private

  def set_defaults
    self.unsubscribed ||= false
    self.locale ||= I18n.locale
  end

end
