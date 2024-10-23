# frozen_string_literal: true
class NewPostEmailSubscribersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    post_id = args.first
    post = Post.find_by_id(post_id)
    unless post
      Rails.logger.error "Job couldn't find post with id of #{post_id}"
      return
    end
    Rails.logger.info "Performing job #{self.class} for post id:#{post.id}, title: #{post.title}"
    content = post.erb_content(content: post.content_with_wrapper)
    # TODO: use batching
    EmailSubscription.can_email.each do |sub|
      PostSubscriptionMailer.with(
        post_id: post_id,
        post_title: post.title,
        content: content,
        email: sub.email,
      ).email_subscriber.deliver!
    end
    Rails.logger.info "Done job!"
    # Do something later
  end
end
