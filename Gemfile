source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.0"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 1.4"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails" # TODO: remove or use
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails" # TODO: remove or use
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"
# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  #gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  #gem "capybara"
  #gem "selenium-webdriver"
end

group :deployment do
  gem "kamal"
end
gem "ostruct" # use the gem in order to silence warnings

gem "devise", "~> 4.9" # admin user authentication
gem "activeadmin" # admin console
gem "sidekiq" # background jobs
gem "friendly_id" # url slugs

gem "sassc-rails"
gem "tailwindcss-rails", "~> 2.7"
#gem "cssbundling-rails"

gem "rouge" # syntax highlighting code for blog posts
gem "erubis" # using erb templates from database
