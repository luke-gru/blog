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
      if sub.confirmed?
        flash[:error] = "You're already subscribed to the email list."
      else
        flash[:error] = "Please confirm your account. We sent you an email with a confirmation link."
      end
      redirect_back(fallback_location: posts_path) and return
    end
    # Otherwise, subscribe them again since they're now unsubscribed
    if sub
      sub.update!(
        unsubscribed: false,
        last_subscribe_action: Time.zone.now,
        confirmed_at: nil,
      )
      # We don't regenerate the token or re-send the email to avoid spamming people
      flash[:notice] = "Check your email for the confirmation link we sent you last time and use this link to confirm your subscription."
    # new subscriber
    else
      sub = EmailSubscription.new(
        email: email,
        last_subscribe_action: Time.zone.now,
        locale: I18n.locale,
      )
      sub.save!
      PostSubscriptionConfirmationMailer.with(sub_id: sub.id).confirmation_email.deliver_later!
      flash[:notice] = "You've successfully been added to the email list. Please check your email to confirm it's you."
    end
    redirect_back(fallback_location: posts_page_path)
  end

  # @params :token
  def unsubscribe
    token = params[:token].presence
    unless token
      flash[:error] = "Invalid token."
      redirect_to(posts_page_path) and return
    end
    sub = EmailSubscription.where(unsubscribe_token: token).last
    unless sub
      flash[:error] = "Cannot find a subscription with this token."
      redirect_to(posts_page_path) and return
    end
    sub.update!(
      last_subscribe_action: Time.zone.now,
      unsubscribed: true,
    )
    flash[:notice] = "You've successfully been unsubscribed."
    redirect_to(posts_page_path) and return
  end

  # @params :token
  def subscribe_confirm
    token = params[:token].presence
    unless token
      flash[:error] = "Invalid token."
      redirect_to(posts_page_path) and return
    end
    sub = EmailSubscription.where(confirmation_token: token).last
    unless sub
      flash[:error] = "Cannot find a subscription with this token."
      redirect_to(posts_page_path) and return
    end
    sub.update!(
      confirmed_at: Time.zone.now,
      unsubscribed: false,
    )
    flash[:notice] = "Confirmation success."
    redirect_to(posts_page_path) and return
  end
end
