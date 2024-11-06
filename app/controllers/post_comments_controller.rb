# frozen_string_literal: true
class PostCommentsController < ApplicationController
  before_action :get_post, only: [:index, :create]
  before_action :get_my_comment, only: [:update, :destroy]

  # @params :post_id (slug)
  def index
    comments = @post.comments.recent_first.to_a
    my_comments = cookies.signed[:comments_created] || []
    my_comments = my_comments.map { |cid| decode_id(cid).to_i }
    comments = comments.select do |comment|
      comment.whitelisted? || my_comments.include?(comment.id)
    end
    render json: {
      comments: CommentsApi.new(comments, mine: my_comments)
    }
  end

  # @params :comment, :username, :post_id (slug)
  def create
    # TODO: rate-limit comments by ip address
    comment = PostComment.new(params.permit(:comment, :username))
    comment.post = @post
    comment.ip_address = request.remote_ip
    if comment.save
      logger.info "Successfully created comment"
      render json: { success: true }
      # TODO: check if this works
      cookies.signed[:comments_created] ||= []
      cookies.signed[:comments_created] << encode_id(comment.id.to_s)
    else
      logger.info "Error creating post comment"
      render json: {
        success: false,
        errors: comment.errors.messages.slice(:comment, :username)
      }
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
    # TODO: rate-limit comment updates by ip address
    @comment.comment = new_comment
    if @comment.save
      render json: { success: true }
    else
      logger.info "Unable to save comment"
      render json: {
        success: false,
        errors: @comment.errors.messages
      }
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
      }, status: :unprocessable_entity
      return
    end
    unless (cookies.signed[:comments_created] || []).include?(comment_id)
      logger.info "Can't update comment id that's not in cookie"
      render json: {
        success: false,
      }, status: :unprocessable_entity
      return
    end
    comment_id = decode_id(comment_id).to_i
    # TODO: rate-limit comment updates by ip address
    @comment = PostComment.find_by_id(comment_id)
    unless @comment
      logger.info "Comment not found after decoding id (#{comment_id})"
      render json: {
        success: false,
      }, status: :unprocessable_entity
      return
    end
  end

  def get_post
    @post = Post.friendly.find(params[:post_id], allow_nil: true)
    unless post
      logger.info "No post with this id"
      render json: {
        success: false,
        post_not_found: true,
      }, status: :unprocessable_entity
      return
    end
  end

  def encode_id(string_id)
    PostComment.encode_id(string_id)
  end

  def decode_id(string_id_enc)
    PostComment.decode_id(string_id_enc)
  end
end
