source 'https://rubygems.org'

ruby '2.4.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.0'

# Use SCSS for stylesheets
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# Use jquery as the JavaScript library
gem 'jquery-rails'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :production do
  gem 'unicorn'
  gem 'rails_12factor'
end

group :test do
  gem 'webmock'
  gem 'codeclimate-test-reporter', require: nil
  gem 'simplecov'
  gem 'stub_env'
  gem 'rails-controller-testing'
end

group :development, :test do
  gem 'pry-byebug'
  gem 'rspec-rails'
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

gem 'therubyracer'
gem 'mongoid', '~> 6'
gem 'kaminari-mongoid'
gem 'kaminari-actionview'
gem 'httparty'
gem 'rack-cors', require: 'rack/cors'
gem 'redis'
gem 'bootstrap-sass', '~> 3.1.1'
gem 'dotiw'
gem 'devise'
gem 'pusher'
gem 'interactor', '~> 3.0'
gem 'rollbar'
gem 'oj'
gem 'webpacker', '~> 3.0'
