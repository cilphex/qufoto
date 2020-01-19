class Info < ActiveRecord::Base
  belongs_to :user
    
  # This bunch of methods sets the boolean flag
  # on these attributes so we don't have to do the
  # lookup on S3
  
  %w(audio banner biopic favicon resume splash bgimage).each do |m|
    self.instance_eval do
      # Create add_ method for each
      define_method("add_#{m}") do
        update_attribute(m, true)
      end
    
      # Create remove_ method for each
      define_method("remove_#{m}") do
        update_attribute(m, false)
      end
    end
    
    # Create boolean display methods which hook into existing
    # display attribute, but now only if file has been uploaded
    define_method("display_#{m}?") do
      send("#{m}display?") && send("#{m}?")
    end
  end
  
  def display_favicon?
    favicon
  end
  
  def display_audio?
    audio
  end
  
end
