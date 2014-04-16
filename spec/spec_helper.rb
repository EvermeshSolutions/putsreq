require 'simplecov'
SimpleCov.start

require 'pry-byebug'
require 'database_cleaner'
require 'mongoid'
require 'rack'

ENV['RACK_ENV'] = 'test'

Mongoid.load!('./config/mongoid.yml')

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
end
