require 'simplecov'
SimpleCov.start

require 'pry-byebug'
require 'database_cleaner'
require 'mongoid'
require 'rack'
require "rack/test"
require 'active_support/all'

ENV['RACK_ENV'] = 'test'

Mongoid.load!('./config/mongoid.yml')

Dir['./spec/support/**/*.rb'].each &method(:require)

require './app'
# Dir['./models/**/*.rb'].each &method(:require)
Dir['./models/**/*.rb'].each &method(:require)

Dir['./spec/support/**/*.rb'].each &method(:require)

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include RequestHelper
end
