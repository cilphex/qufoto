class Image < ActiveRecord::Base
  
  belongs_to :portfolio, :counter_cache => true
  belongs_to :interview, :counter_cache => true
  
  @@maxProW = 920
  @@maxProH = 562
  @@maxStudentW = 775
  @@maxStudentH = 518
  @@max370tallH = 370
  @@max370tallW = 1000
  @@maxThumbW = 100
  @@maxThumbH = 100
  
  def file=(fileContents)
    pic = Magick::Image.from_blob(fileContents.read).first
    pic.resize_to_fit!(@@maxProW, @@maxProH) if pic.columns > @@maxProW or pic.rows > @@maxProH
    AWS::S3::S3Object.store self.id.to_s + "_pro.jpg", pic.to_blob {self.quality = 90}, IMAGES_BUCKET.to_s, :access => :public_read
    
    pic.resize_to_fit!(@@maxStudentW, @@maxStudentH) if pic.columns > @@maxStudentW or pic.rows > @@maxStudentH
    AWS::S3::S3Object.store self.id.to_s + "_student.jpg", pic.to_blob {self.quality = 90}, IMAGES_BUCKET.to_s, :access => :public_read
    
    pic.resize_to_fit!(@@max370tallW, @@max370tallH) if pic.columns > @@max370tallW or pic.rows > @@max370tallH
    AWS::S3::S3Object.store self.id.to_s + "_370tall.jpg", pic.to_blob {self.quality = 90}, IMAGES_BUCKET.to_s, :access => :public_read
    
    pic.resize_to_fit!(@@maxThumbW, @@maxThumbH) if pic.columns > @@maxThumbW or pic.rows > @@maxThumbH
    AWS::S3::S3Object.store self.id.to_s + "_thumb.jpg", pic.to_blob {self.quality = 90}, IMAGES_BUCKET.to_s, :access => :public_read
  end
  
  def fileRollover=(fileContents)
    pic = Magick::Image.from_blob(fileContents.read).first
    pic.resize_to_fit!(@@maxProW, @@maxProH) if pic.columns > @@maxProW or pic.rows > @@maxProH
    AWS::S3::S3Object.store self.id.to_s + "_pro_rollover.jpg", pic.to_blob {self.quality = 90}, IMAGES_BUCKET.to_s, :access => :public_read
    
    pic.resize_to_fit!(@@maxStudentW, @@maxStudentH) if pic.columns > @@maxStudentW or pic.rows > @@maxStudentH 
    AWS::S3::S3Object.store self.id.to_s + "_student_rollover.jpg", pic.to_blob {self.quality = 90}, IMAGES_BUCKET.to_s, :access => :public_read
    
    pic.resize_to_fit!(@@max370tallW, @@max370tallH) if pic.columns > @@max370tallW or pic.rows > @@max370tallH
    AWS::S3::S3Object.store self.id.to_s + "_370tall_rollover.jpg", pic.to_blob {self.quality = 90}, IMAGES_BUCKET.to_s, :access => :public_read
    
    pic.resize_to_fit!(@@maxThumbW, @@maxThumbH) if pic.columns > @@maxThumbW or pic.rows > @@maxThumbH
    AWS::S3::S3Object.store self.id.to_s + "_thumb_rollover.jpg", pic.to_blob {self.quality = 90}, IMAGES_BUCKET.to_s, :access => :public_read
  end
  
  def delete_s3
    AWS::S3::S3Object.delete self.id.to_s + "_pro.jpg", IMAGES_BUCKET.to_s
    AWS::S3::S3Object.delete self.id.to_s + "_student.jpg", IMAGES_BUCKET.to_s
    AWS::S3::S3Object.delete self.id.to_s + "_370tall.jpg", IMAGES_BUCKET.to_s
    AWS::S3::S3Object.delete self.id.to_s + "_thumb.jpg", IMAGES_BUCKET.to_s
    
    if self.rollover
      AWS::S3::S3Object.delete self.id.to_s + "_pro_rollover.jpg", IMAGES_BUCKET.to_s
      AWS::S3::S3Object.delete self.id.to_s + "_student_rollover.jpg", IMAGES_BUCKET.to_s
      AWS::S3::S3Object.delete self.id.to_s + "_370tall_rollover.jpg", IMAGES_BUCKET.to_s
      AWS::S3::S3Object.delete self.id.to_s + "_thumb_rollover.jpg", IMAGES_BUCKET.to_s
    end
  end
end
