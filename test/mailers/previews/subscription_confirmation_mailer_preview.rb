# Preview all emails at http://localhost:3000/rails/mailers/post_subscription_mailer
class SubscriptionConfirmationMailerPreview < ActionMailer::Preview
  def confirmation_email
    sub = EmailSubscription.where(confirmed_at: nil).last
    if !sub
    end
    sub = EmailSubscription.last
    if !sub
      raise "No subscription without confirmation"
    end
    SubscriptionConfirmationMailer.with(
      sub_id: sub.id,
    ).confirmation_email
  end
end
