# frozen_string_literal: true
class NewPostSubscriptionMailer < ApplicationMailer
  layout "post_mailer"
  helper "post"

  def email_subscriber
    @post_id = params[:post_id]
    @unsubscribe_token = params[:unsubscribe_token]
    @locale = params[:locale].presence || I18n.locale
    sub_id = params[:sub_id]
    email = params[:email]
    @post = Post.find_by_id(@post_id)

    # TODO: translate
    subject = "New post: #{@post_title}"
    result = mail(to: email, subject: subject)
    # save model to the database
    email_sent = SubscriptionEmailSent.new(
      post_id: @post_id,
      email_subscription_id: sub_id,
      to: email,
      subject: subject,
      content: result.body,
      locale: @locale,
    )
    unless email_sent.save
      Rails.logger.error "mailer #{self.class}: error saving SubscriptionEmailSent: #{email_sent.errors.full_messages.join(', ')}"
    end
    result
  end
end
