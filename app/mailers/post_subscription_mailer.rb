# frozen_string_literal: true
class PostSubscriptionMailer < ApplicationMailer
  layout "post_mailer"

  def email_subscriber
    @post_id = params[:post_id]
    @content = params[:content]
    post_title = params[:post_title]
    #@content = @post.erb_content(@post.content_with_wrapper)
    email = params[:email]

    mail(to: email, subject: "New post: #{post_title}")
  end
end
