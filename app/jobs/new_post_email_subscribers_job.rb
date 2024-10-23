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
    # TODO: deliver the mail!
    sleep 60
    Rails.logger.info "Done job!"
    # Do something later
  end
end
