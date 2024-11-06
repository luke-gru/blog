# frozen_string_literal: true
Rails.application.routes.draw do
  # user login routes and other devise routes namespaced under /admin/
  devise_for :users, ActiveAdmin::Devise.config

  authenticate :user, ->(user) { user.admin? } do
    ActiveAdmin.routes(self)
    require 'sidekiq/web'
    mount Sidekiq::Web => '/admin/sidekiq', as: :sidekiq_dashboard
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  scope ':locale', constraints: { locale: /en|fr/ } do
    root to: "posts#index"
    get  "posts", to: "posts#index", as: :posts_page
    post "posts/subscribe", to: "posts#subscribe", as: :posts_subscribe
    get  "posts/unsubscribe-form/:token", to: "posts#unsubscribe_form", as: :posts_unsubscribe_form
    post "posts/unsubscribe/:token", to: "posts#unsubscribe", as: :posts_unsubscribe
    get  "posts/subscribe-confirm/:token", to: "posts#subscribe_confirm", as: :posts_subscribe_confirm
    get  "posts/:id", to: "posts#show", as: :post_page

    defaults format: :json do
      post   "post-comments/create", to: "post_comments#create", as: :post_comments_create
      patch  "post-comments/update", to: "post_comments#update", as: :post_comments_update
      delete "post-comments/delete", to: "post_comments#destroy", as: :post_comments_delete
    end
  end

  # redirect to /en/some-url if url doesn't start with /en or /fr
  match '*path', via: [:get, :post], to: redirect("/#{I18n.default_locale}/%{path}"), constraints: lambda { |req|
    !req.path.start_with?("/#{I18n.default_locale}/") && !req.path.start_with?("/rails/")
  }
  match '', via: [:get, :post], to: redirect("/#{I18n.default_locale}")
end
