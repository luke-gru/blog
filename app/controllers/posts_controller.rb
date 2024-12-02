# frozen_string_literal: true
class PostsController < ApplicationController
  before_action :set_tags_param, only: [:index]

  # @params [:search], [:tags]
  def index
    @posts = Post.recently_published(
      search: params[:search],
      tag: @tags_param,
    ).to_a

    if @tags_param.present?
      @tags = Tag.where(tag: @tags_param).to_a
    else
      @tags = []
    end
    @post_tags = {}
    @posts.each do |p|
      # show all tags per post, even if filtering by tag
      @post_tags[p] = p.reload.tags.to_a
    end
  end

  # @params :id (slug)
  def show
    @post = Post.friendly.find(params[:id], allow_nil: true)
    unless @post
      logger.info "No post with this id"
      redirect_to(posts_page_path) and return
    end
    if !@post.published? && (current_user.blank? || !current_user.admin?)
      logger.info "Post not published, no access"
      redirect_to(posts_page_path) and return
    end
    @tags = @post.tags.to_a
  end

  # TODO: move to different controller (EmailSubscriptions)
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
      redirect_back(fallback_location: posts_page_path) and return
    end
    # Otherwise, subscribe them again since they're now unsubscribed
    if sub
      logger.info "Resubscribing EmailSubscription id:#{sub.id}"
      sub.resubscribe!
      # We don't regenerate the token or re-send the email to avoid spamming someone if they
      # use another person's email address
      flash[:notice] = "Check your email for the confirmation link we sent you last time and use this link to confirm your subscription."
    # new subscriber
    else
      logger.info "Subscribing email '#{email}'"
      sub = EmailSubscription.create!(
        email: email,
        last_subscribe_action: Time.zone.now,
        locale: I18n.locale,
      )
      SubscriptionConfirmationMailer.with(
        sub_id: sub.id
      ).confirmation_email.deliver_later!
      flash[:notice] = "You've successfully been added to the email list. Please check your email to confirm it's you."
    end
    redirect_back(fallback_location: posts_page_path)
  end

  # @params :token
  def unsubscribe_form
    token = params[:token].presence
    unless token
      logger.info "Token empty"
      flash[:error] = "Invalid token."
      redirect_to(posts_page_path) and return
    end
    @sub = EmailSubscription.where(unsubscribe_token: token).last
    unless @sub
      logger.info "No sub with this token"
      flash[:error] = "Cannot find a subscription with this token."
      redirect_to(posts_page_path) and return
    end
    if @sub.unsubscribed?
      logger.info "subscription already unsubbed"
      flash.now[:notice] = "You are already unsubscribed"
    end
    @skip_footer_subscribe_form = true
  end


  # TODO: move to different controller (EmailSubscriptions)
  # POST
  # @params :token, :reason
  def unsubscribe
    token = params[:token].presence
    unless token
      logger.info "Token empty"
      flash[:error] = "Invalid token."
      redirect_to(posts_page_path) and return
    end
    sub = EmailSubscription.where(unsubscribe_token: token).last
    unless sub
      logger.info "No sub with this token"
      flash[:error] = "Cannot find a subscription with this token."
      redirect_to(posts_page_path) and return
    end
    logger.info "Unsubbing EmailSubscription id:#{sub.id}"
    sub.unsubscribe!(reason: params[:reason])
    flash[:notice] = "You've successfully been unsubscribed."
    redirect_to(posts_page_path) and return
  end

  # TODO: move to different controller (EmailSubscriptions)
  # GET
  # @params :token
  def subscribe_confirm
    token = params[:token].presence
    unless token
      logger.info "Empty token"
      flash[:error] = "Invalid token."
      redirect_to(posts_page_path) and return
    end
    sub = EmailSubscription.where(confirmation_token: token).last
    unless sub
      logger.info "No sub with this token"
      flash[:error] = "Cannot find a subscription with this token."
      redirect_to(posts_page_path) and return
    end
    sub.confirm!
    logger.info "Confirmation success"
    flash[:notice] = "Confirmation success."
    redirect_to(posts_page_path) and return
  end

  private

  def set_tags_param
    @tags_param = params[:tags].presence
    unless Array === @tags_param && @tags_param.all? { |e| String === e }
      @tags_param = []
    end
  end
end
