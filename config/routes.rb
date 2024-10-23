Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  authenticate :user, ->(user) { user.admin? } do
    ActiveAdmin.routes(self)
  end

  scope ':locale', constraints: { locale: /en|fr/ } do
    root to: "posts#index"
    get "posts", to: "posts#index", as: :posts_page
    get "posts/:id", to: "posts#show", as: :post_page
  end
  match '*path', via: [:get, :post], to: redirect("/#{I18n.default_locale}/%{path}"), constraints: lambda { |req|
    !req.path.start_with?("/#{I18n.default_locale}/") && !req.path.start_with?("/rails/active_storage")
  }
  match '', via: [:get, :post], to: redirect("/#{I18n.default_locale}")
end
