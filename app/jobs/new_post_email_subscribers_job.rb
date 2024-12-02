# frozen_string_literal: true
class NewPostEmailSubscribersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    post_id = args.first
    post = Post.find_by_id(post_id)
    unless post
      Rails.logger.error "Job #{self.class} couldn't find post with id: '#{post_id}'"
      return
    end
    Rails.logger.info "Performing job #{self.class} for post id:#{post_id}"
    # TODO: use batching
    EmailSubscription.can_email.each do |sub|
      NewPostSubscriptionMailer.with(
        post_id: post_id,
        sub_id: sub.id,
        unsubscribe_token: sub.unsubscribe_token,
        locale: sub.locale,
        email: sub.email,
      ).email_subscriber.deliver!
    end
    Rails.logger.info "Done job #{self.class} for post id:#{post_id}"
  end
end
