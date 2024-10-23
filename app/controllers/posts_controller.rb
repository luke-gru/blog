class PostsController < ApplicationController
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

  def show
    @post = Post.find_by_id(params[:id])
    unless @post
      redirect_to(root_path) and return
    end
    if !@post.published? && !(current_user && current_user.admin?)
      redirect_to(root_path) and return
    end
  end
end
