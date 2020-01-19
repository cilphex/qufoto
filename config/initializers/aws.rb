require 'rubygems'
require 'aws/s3'

AWS::S3::Base.establish_connection!(
  :access_key_id => '1P115X39F721HH8K8R82',
  :secret_access_key => '8mXPwFRy3wI7K9QCwfsGfXu3pbRQSbbZCNUERGOX',
  :persistent => false    # Defaults to true.  Try false if you're experiencing connection errors?
)

if ENV['RAILS_ENV'] == 'production'
  QBUCKET = 'images.qufoto.com'
  IMAGES_BUCKET = 'images.qufoto.com'
else
  QBUCKET = 'qufoto-development1'
  IMAGES_BUCKET = 'qufoto-development1'
end