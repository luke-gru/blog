Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  authenticate :user, ->(user) { user.admin? } do
    ActiveAdmin.routes(self)
  end

  # Defines the root path route ("/")
  root "posts#index"
end
