# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # Helper methods for s3 path
  {:audio => "mp3", :banner => "jpg", :biopic => "jpg", :favicon => "ico", :resume => "pdf", :splash => "jpg", :background => "jpg"}.each do |k,v|
    define_method("#{k}_s3_path") do |user|
      return "#{k}#{user.id}.#{v}"
    end
  end
  
  # Seperate method for portfolio_audio as this doesn't fit the pattern
  def portfolio_audio_s3_path(portfolio)
    "portfolio_audio#{portfolio.id}.mp3"
  end

  # Return the URL of a publicly accessible file
  def s3_file(file)
    if ENV['RAILS_ENV'] == 'production'
      "http://images.qufoto.com/#{file}"
    else
      AWS::S3::S3Object.url_for(file, QBUCKET.to_s, :authenticated => false)
    end
  end
  
  # Return the location of the file at AWS
  def s3_photo(id, size)
#    if size == "thumb"
#      s3_file("#{id.to_s}_thumb.jpg")
#    else
#      AWS::S3::S3Object.url_for(id.to_s + '_' + size + '.jpg', QBUCKET.to_s, :expires_in => 86400 * 360) # 24 hours
#      # Images are currently uploaded without public_read access
#      # AWS::S3::S3Object.url_for(id.to_s + '_' + size + '.jpg', QBUCKET.to_s, :authenticated => false)
#    end
    if ENV['RAILS_ENV'] == 'production'
      "http://images.qufoto.com/#{id.to_s}_#{size}.jpg"
    else
      AWS::S3::S3Object.url_for(id.to_s + '_' + size + '.jpg', QBUCKET.to_s, :authenticated => false)
    end
  end
  
  # Tell whether the specified file is in S3
  def s3_contains(file)
    #AWS::S3::S3Object.exists?(file, QBUCKET.to_s)
    AWS::S3::S3Object.exists?(file, IMAGES_BUCKET.to_s)
  end
  
  #
  #
  # delete files the right way when accounts are deleted
  #
  #
  
end
