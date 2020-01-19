class ImageController < ApplicationController
  @@thumb_size = 100
  def resize_s3_image
    maxw = params['width'].nil? ? @@thumb_size : params['width']
    maxh = params['height'].nil? ? @@thumb_size : params['height']
    pic = Magick::Image.read("http://s3.amazonaws.com/#{IMAGES_BUCKET.to_s}/#{params['file']}").first
    pic.format = "JPEG"
    render :text => pic.resize_to_fit(maxw, maxh).to_blob
  end
  
  def resize_s3_photo #params id, size, maxw, maxh
    maxw = params['width'].nil? ? @@thumb_size : params['width']
    maxh = params['height'].nil? ? @@thumb_size : params['height']
    if params['size'].to_s == "thumb"
      file = "http://s3.amazonaws.com/#{IMAGES_BUCKET.to_s}/#{params['id'].to_s}_thumb.jpg}"
    else
      file = AWS::S3::S3Object.url_for(params['id'].to_s + '_' + params['size'].to_s + '.jpg', IMAGES_BUCKET.to_s)
    end
    pic = Magick::Image.read(file).first
    pic.format = "JPEG"
    render :text => pic.resize_to_fit(maxw, maxh).to_blob
  end
  
  def url
    size = params[:size].nil? ? 'student' : params[:size]
    if params[:id]
      render :text => @template.s3_photo(params[:id], size)
    else
      render :text => 'No image id'
    end
  end
end
