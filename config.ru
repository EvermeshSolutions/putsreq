require './app'

begin
  # should work only in development
  require 'pry-byebug'
rescue LoadError
  # not installed
end

run PutsReqApp.new