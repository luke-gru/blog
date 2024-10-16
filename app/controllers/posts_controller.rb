class PostsController < ApplicationController
  def index
    @posts = Post.order('created_at DESC').limit(3).to_a
  end

  def show
  end
end
