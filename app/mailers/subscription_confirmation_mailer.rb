# frozen_string_literal: true
class SubscriptionConfirmationMailer < ApplicationMailer
  layout "mailer"

  def confirmation_email
    sub_id = params[:sub_id]
    sub = EmailSubscription.find_by_id(sub_id)
    unless sub
      # TODO: log error and return
      return
    end
    @locale = sub.locale.presence || I18n.default_locale.to_s
    @confirmation_token = sub.confirmation_token
    if @confirmation_token.blank?
      Rails.logger.error "Subscription #{sub.id} has a blank token? from: #{__method__}"
      raise "Subscription #{sub.id} has a blank token?"
    end
    email = sub.email

    mail(to: email, subject: "Confirm your email")
  end
end
