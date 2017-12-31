if ENV['CODECLIMATE_REPO_TOKEN']
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/config/'
  end
end