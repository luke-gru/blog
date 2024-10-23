class PostsController < ApplicationController
  # @params [:search], [:tag]
  def index
    @posts = Post.recently_published(
      search: params[:search],
      tag: params[:tag],
    ).to_a

    if params[:tag].present?
      @tags = @posts.flat_map(&:tags)
    else
      @tags = nil
    end
  end

  # @params :id
  def show
    @post = Post.find_by_id(params[:id])
    unless @post
      redirect_to(root_path) and return
    end
    if !@post.published? || !(current_user && current_user.admin?)
      redirect_to(root_path) and return
    end
  end

  # @params :subscribe_email
  def subscribe
    email = params[:subscribe_email].to_s.strip.downcase
    sub = EmailSubscription.where(email: email).first
    if sub && sub.still_subscribed?
      flash[:error] = "You're already subscribed to the email list"
      redirect_back(fallback_location: posts_path) and return
    end
    # Otherwise, subscribe them
    if sub
      sub.update(unsubscribed: false, last_subscribe_action: Time.zone.now)
    else
      sub = EmailSubscription.new(email: email, last_subscribe_action: Time.zone.now)
      sub.save!
    end
    cookies[:subscribed] = true
    flash[:notice] = "You've successfully been added to the email list"
    redirect_back(fallback_location: posts_page_path)
  end
end
