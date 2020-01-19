class Interview < ActiveRecord::Base
  
  has_many :images, :order => 'position ASC'

  def images
    Image.find(:all, :order => 'position ASC', :conditions => ['interview_id = ? AND id != ?', self.id, self.photographer_picid])
  end

  def photographer_image
    Image.find(:first, :conditions => ['interview_id = ? AND id = ?', self.id, self.photographer_picid])
  end

  def next_interview
    Interview.find(:first, :order => 'id ASC', :conditions => ['id > ? AND enabled = ?', self.id, true])
  end
  
  def prev_interview
    Interview.find(:first, :order => 'id DESC', :conditions => ['id < ? AND enabled = ?', self.id, true])
  end

end
