# frozen_string_literal: true
class SubscriptionConfirmationMailer < ApplicationMailer
  layout "mailer"

  def confirmation_email
    sub_id = params[:sub_id]
    sub = EmailSubscription.find_by_id(sub_id)
    unless sub
      Rails.logger.error "mailer #{self.class} couldn't find EmailSubscription id: '#{sub_id}'"
      return
    end
    @locale = sub.locale.presence || I18n.default_locale.to_s
    @confirmation_token = sub.confirmation_token
    if @confirmation_token.blank?
      Rails.logger.error "EmailSubscription #{sub.id} has a blank confirmation token? from: #{__method__}"
      raise "Subscription #{sub.id} has a blank token?"
    end
    email = sub.email

    # TODO: translate subject
    mail(to: email, subject: "Please confirm your email")
  end
end
