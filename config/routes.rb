Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  authenticate :user, ->(user) { user.admin? } do
    ActiveAdmin.routes(self)
  end

  # Defines the root path route ("/")
  root "posts#index"
  get "posts", to: "posts#index", as: :posts_page
  get "posts/:id", to: "posts#show", as: :post_page
end
