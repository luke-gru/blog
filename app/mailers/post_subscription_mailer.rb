# frozen_string_literal: true
class PostSubscriptionMailer < ApplicationMailer
  layout "post_mailer"

  def email_subscriber
    @post_id = params[:post_id]
    @post_title = params[:post_title]
    @content = params[:content]
    @unsubscribe_token = params[:unsubscribe_token]
    @locale = params[:locale].presence || I18n.locale
    sub_id = params[:sub_id]
    email = params[:email]

    subject = "New post: #{@post_title}"
    result = mail(to: email, subject: subject)
    email_sent = SubscriptionEmailSent.new(
      post_id: @post_id,
      email_subscription_id: sub_id,
      to: email,
      subject: subject,
      content: result.body,
      locale: @locale,
    )
    unless email_sent.save
      Rails.logger.error "Error saving SubscriptionEmailSent: #{email_sent.errors.full_messages.join(', ')}"
    end
    result
  end
end
