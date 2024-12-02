# Preview all emails at http://localhost:3000/rails/mailers/post_subscription_mailer
class NewPostSubscriptionMailerPreview < ActionMailer::Preview
  def email_subscriber
    post = Post.find_by_id(3)
    post = Post.last unless post
    sub = EmailSubscription.can_email.last
    if !sub
      sub = EmailSubscription.last
    end
    NewPostSubscriptionMailer.with(
      post_id: post.id,
      post_title: post.title,
      unsubscribe_token: sub.unsubscribe_token,
      locale: sub.locale.presence || I18n.default_locale.to_s,
      email: sub.email,
    ).email_subscriber
  end
end
