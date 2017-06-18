source 'https://rubygems.org'

ruby '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.0.4'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'therubyracer'
gem 'mongoid' # , github: 'mongoid/mongoid', ref: '4893e77bb858'
gem 'bson_ext'
gem 'httparty'
gem 'kaminari-mongoid'
gem 'rack-cors', require: 'rack/cors'
gem 'redis'

gem 'bootstrap-sass', '~> 3.1.1'

group :production do
  gem 'unicorn'
  gem 'rails_12factor'
end

group :test do
  gem 'webmock'
  gem 'codeclimate-test-reporter', require: nil
  gem 'simplecov'
  gem 'stub_env'
end

group :development do
  gem 'quiet_assets'
end

group :development, :test do
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 3.3'
  gem 'rack-test'
  gem 'database_cleaner'
  gem 'dotenv-rails'
end

source 'https://rails-assets.org' do
  gem 'rails-assets-favico.js'
  gem 'rails-assets-dispatcher'
  gem 'rails-assets-bootstrap-less'
  gem 'rails-assets-clipboard'
end

gem 'dotiw'
gem 'devise'
gem 'pusher'
gem 'interactor', '~> 3.0'
gem 'staccato'
gem 'rollbar'
gem 'oj', '~> 2.12.14'
