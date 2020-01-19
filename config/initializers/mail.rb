ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.default_charset = "utf-8"
ActionMailer::Base.sendmail_settings = {
  :address => 'localhost',
  :port => 25,
  :domain => 'qufoto.com'
}


#ActionMailer::Base.sendmail_settings = {
#  :location   => '/usr/sbin/sendmail'
#}


#ActionMailer::Base.smtp_settings = {
#  :address => "mail.qufoto.com",
#  :port => 25,
#  :domain => "qufoto.com",
#  :user_name => "service+qufoto.com",
#  :password => "lament",
#  :authentication => :login
#}