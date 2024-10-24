Rails.application.routes.draw do
  # user login routes and other devise routes namespaced under /admin/
  devise_for :users, ActiveAdmin::Devise.config

  authenticate :user, ->(user) { user.admin? } do
    ActiveAdmin.routes(self)
    require 'sidekiq/web'
    mount Sidekiq::Web => '/admin/sidekiq', as: :sidekiq_dashboard
  end

  scope ':locale', constraints: { locale: /en|fr/ } do
    root to: "posts#index"
    get  "posts", to: "posts#index", as: :posts_page
    post "posts/subscribe", to: "posts#subscribe", as: :posts_subscribe
    get  "posts/unsubscribe", to: "posts#unsubscribe", as: :posts_unsubscribe
    get  "posts/subscribe-confirm", to: "posts#subscribe_confirm", as: :posts_subscribe_confirm
    get  "posts/:id", to: "posts#show", as: :post_page
  end

  # redirect to /en/some-url if url doesn't start with /en or /fr
  match '*path', via: [:get, :post], to: redirect("/#{I18n.default_locale}/%{path}"), constraints: lambda { |req|
    !req.path.start_with?("/#{I18n.default_locale}/") && !req.path.start_with?("/rails/")
  }
  match '', via: [:get, :post], to: redirect("/#{I18n.default_locale}")
end
