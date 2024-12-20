# frozen_string_literal: true
class PostCommentsController < ApplicationController
  before_action :get_post, only: [:index, :create]
  before_action :get_my_comment, only: [:update, :destroy]
  before_action :rate_limit_by_ip, only: [:create, :update]

  # @params :post_id (slug)
  def index
    comments = @post.comments.recent_first.to_a
    my_comments = cookies.signed[:comments_created] || []
    my_comments = my_comments.map { |cid| decode_id(cid).to_i }
    # user can view their own comments and whitelisted comments from others
    comments = comments.select do |comment|
      comment.whitelisted? || my_comments.include?(comment.id)
    end
    render json: {
      comments: CommentsApi.new(comments, mine: my_comments)
    }
  end

  # @params :comment, :username, :post_id (slug)
  def create
    comment = PostComment.new(params.permit(:comment, :username))
    comment.post = @post
    comment.ip_address = request.remote_ip
    if comment.save
      logger.info "Successfully created comment"
      # TODO: check if this works
      cookies.signed[:comments_created] ||= []
      cookies.signed[:comments_created] << encode_id(comment.id.to_s)
      render json: { success: true }
    else
      logger.info "Error creating post comment: #{comment.errors.full_messages.join(', ')}"
      render json: {
        success: false,
        errors: comment.errors.messages.slice(:comment, :username)
      }, status: :unprocessable_entity
    end
  end

  # @params :comment_id (encoded), :comment
  def update
    new_comment = params[:comment]
    if new_comment.blank?
      logger.info "Comment can't be blank!"
      render json: {
        success: false,
        errors: { comment: "Can't be blank" }
      }
      return
    end
    @comment.comment = new_comment
    if @comment.save
      render json: { success: true }
    else
      logger.info "Unable to save comment: #{@comment.errors.full_messages.join(', ')}"
      render json: {
        success: false,
        errors: @comment.errors.messages
      }, status: :unprocessable_entity
    end
  end

  # @params :comment_id (encoded)
  def destroy
    @comment.destroy
    logger.info "Comment successfully deleted"
    render json: { success: true }
  end

  private

  def get_my_comment
    comment_id = params[:comment_id].to_s
    if comment_id.blank?
      logger.info "Invalid comment id (blank)"
      render json: {
        success: false,
        invalid_comment_id: true,
      }, status: :unprocessable_entity
      return
    end
    unless (cookies.signed[:comments_created] || []).include?(comment_id)
      logger.info "Can't update comment id that's not in cookie"
      render json: {
        success: false,
        invalid_cookie: true,
      }, status: :unprocessable_entity
      return
    end
    comment_id = decode_id(comment_id).to_i
    @comment = PostComment.find_by_id(comment_id)
    unless @comment
      logger.info "Comment not found after decoding id (#{comment_id})"
      render json: {
        success: false,
        comment_not_found: true,
      }, status: :unprocessable_entity
      return
    end
  end

  def get_post
    @post = Post.friendly.find(params[:post_id], allow_nil: true)
    unless @post
      logger.info "No post with this id"
      render json: {
        success: false,
        post_not_found: true,
      }, status: :unprocessable_entity
      return
    end
  end

  def rate_limit_by_ip
    ip = request.remote_ip
    if action_name == "create"
      if PostComment.recently_created_by_ip(ip: ip, time_cutoff: 10.minutes.ago).count >= 2
        logger.info "This user already created 2 comments within the last 10 minutes. Rate limited."
        render json: {
          success: false,
          rate_limited: true,
          rate_limited_create: true,
        }, status: :unprocessable_entity
        return
      end
    elsif action_name == "update"
      if PostComment.recently_updated_by_ip(ip: ip, time_cutoff: 2.minutes.ago).count > 0
        logger.info "This user already updated a comment within the last 2 minutes. Rate limited."
        render json: {
          success: false,
          rate_limited: true,
          rate_limit_update: true,
        }, status: :unprocessable_entity
      end
    end
  end

  def encode_id(string_id)
    PostComment.encode_id(string_id)
  end

  def decode_id(string_id_enc)
    PostComment.decode_id(string_id_enc)
  end
end
