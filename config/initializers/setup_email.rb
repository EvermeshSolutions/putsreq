if ENV['MANDRILL_USERNAME'] && ENV['MANDRILL_APIKEY']
  ActionMailer::Base.smtp_settings = {
    port:            '587',
    address:         'smtp.mandrillapp.com',
    user_name:       ENV['MANDRILL_USERNAME'],
    password:        ENV['MANDRILL_APIKEY'],
    domain:          'heroku.com',
    authentication:  :plain
  }
  ActionMailer::Base.delivery_method = :smtp
end
