require "test_helper"

class NewPostEmailSubscribersJobTest < ActiveJob::TestCase
  test "a newly published post sends emails out" do
    post = posts(:draft_no_tags)
    post.status = "published"
    assert_enqueued_with(job: NewPostEmailSubscribersJob) do
      post.save!
    end
  end

  test "the job sends emails and saves records in the database" do
    post = posts(:draft_no_tags)
    sub = email_subscriptions(:reader_confirmed_email)
    post.status = "published"
    post.save!
    assert_difference "SubscriptionEmailSent.count", 1 do
      perform_enqueued_jobs
    end

    email = SubscriptionEmailSent.last
    assert_equal post, email.post
    assert_equal sub, email.email_subscription
    assert_not_empty email.content
    assert_not_empty email.subject
    assert_equal sub.email, email.to
  end
end
