require "test_helper"

class EmailSubscriptionTest < ActiveSupport::TestCase

  def test_tokens_and_defaults
    sub = create_sub!
    assert sub.confirmation_token.present?
    assert sub.unsubscribe_token.present?
    assert sub.locale.present?
    refute sub.confirmed?
    refute sub.unsubscribed?
  end

  def test_can_email_when_confirmed
    sub = create_sub!
    scope = EmailSubscription.can_email.where(email: sub.email)
    assert_equal 0, scope.size
    sub.update!(confirmed_at: Time.zone.now)
    assert_equal 1, scope.size
    sub.unsubscribe!
    assert_equal 0, scope.size
    sub.resubscribe! # sets confirmed_at back to nil
    assert_equal 0, scope.size
    sub.confirm!
    assert_equal 1, scope.size
  end

  private

  def create_sub!(email: "lukeg3000@gmail.com")
    sub = EmailSubscription.create!(
      email: email
    )
  end
end
