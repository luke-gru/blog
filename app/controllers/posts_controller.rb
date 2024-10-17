class PostsController < ApplicationController
  def index
    @posts = Post.published.order('created_at DESC').limit(3).to_a
  end

  def show
    @post = Post.find_by_id(params[:id])
    unless @post
      redirect_to(:root) and return
    end
    if !@post.published? && !(current_user && current_user.admin?)
      redirect_to(:root) and return
    end
  end
end
