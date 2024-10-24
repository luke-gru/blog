# frozen_string_literal: true
class PostSubscriptionMailer < ApplicationMailer
  layout "post_mailer"

  def email_subscriber
    @post_id = params[:post_id]
    @post_title = params[:post_title]
    @content = params[:content]
    @unsubscribe_token = params[:unsubscribe_token]
    @locale = params[:locale].presence || I18n.locale
    email = params[:email]

    mail(to: email, subject: "New post: #{@post_title}")
  end
end
