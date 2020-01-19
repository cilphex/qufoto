class Portfolio < ActiveRecord::Base
  
  belongs_to :user, :counter_cache => true
  has_many :images, :order => "position ASC"
  
  # Check the portfolio has images and is not hidden
  def has_images?
    images.length > 0 && hidden == false
  end
  
  def self.visible?
    hidden == false
  end
  
  # Flag audio for portfolio
  def add_audio
    update_attribute(:audio, true)
  end
  
  # Remove audio flag
  def remove_audio
    update_attribute(:audio, false)
  end
  
end
