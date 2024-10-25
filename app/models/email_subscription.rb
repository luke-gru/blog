# frozen_string_literal: true
class EmailSubscription < ApplicationRecord
  has_many :emails_sent, class_name: "SubscriptionEmailSent"

  has_secure_token :unsubscribe_token, length: 50
  has_secure_token :confirmation_token, length: 50

  validates :email, presence: true, uniqueness: true
  validates :unsubscribe_token, presence: true
  validates :confirmation_token, presence: true
  validates :unsubscribed, inclusion: [true, false]
  validates :locale, inclusion: I18n.available_locales.map(&:to_s) + ["",nil]

  before_validation :set_defaults, on: :create

  def self.ransackable_attributes(auth_object = nil)
    ["confirmation_token", "confirmed_at", "created_at", "email", "id", "id_value", "last_subscribe_action", "last_unsubscribe_action", "locale", "unsubscribe_reason", "unsubscribe_token", "unsubscribed", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["emails_sent"]
  end

  def self.can_email
    confirmed.still_subscribed
  end

  def self.still_subscribed
    where(email_subscriptions: { unsubscribed: false })
  end

  def self.confirmed
    where.not(email_subscriptions: { confirmed_at: nil })
  end

  def unsubscribe!(reason: nil)
    update!(
      unsubscribed: true,
      unsubscribe_reason: reason,
      last_subscribe_action: Time.zone.now,
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

  # @return Hash
  def resend_confirmation_email!(inline: true, inline_timeout: 20)
    result = {}
    sub_id = self.id
    if !inline
      SubscriptionConfirmationMailer.with(
        sub_id: sub_id
      ).confirmation_email.deliver_later!
      result[:success] = true
      return result
    end
    begin
      Timeout.timeout(inline_timeout) do
        SubscriptionConfirmationMailer.with(
          sub_id: sub_id
        ).confirmation_email.deliver!
      end
    rescue Timeout::Error => e
      result[:error] = "#{e.class}: #{e.message}. Warning: The email MAY have been sent."
      return result
    rescue => e # other delivery errors
      result[:error] = "#{e.class}: #{e.message}. Warning: The email MAY have been sent."
      return result
    end
    result[:success] = true
    result
  end

  private

  def set_defaults
    self.unsubscribed ||= false
    self.locale ||= I18n.locale
  end

end
