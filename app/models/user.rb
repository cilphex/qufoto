class User < ActiveRecord::Base
  
  has_one :info
  has_many :portfolios, :order => "position ASC"
  has_many :comments, :order => "date DESC"
  
  before_create :create_info
  
  def self.authenticate(user, pass)
    find(:first, :conditions => ["user = ? AND pass = ?", user, pass])
  end
  
  def update_last_action
    update_attribute(:last_action, Time.now)
  end
  
  #def online?
  #  self.onlines.last.updated_at > Time.now - 10.minutes unless self.onlines.last.nil?
  #end
  
  def grade_text
    case self.grade
      when 'Lite' then 'Standard'
      when 'Pro' then 'Pro'
      else 'Admin'
    end
  end
  
  def online_title
    last_time_online, now = read_attribute(:last_action), Time.now
    if last_time_online
      case (now - last_time_online)
        when 0.minutes..5.minutes then "5 minutes"
        when 5.minutes..10.minutes then "10 minutes"
        when 10.minutes..30.minutes then "30 minutes"
        when 30.minutes..1.hours then "1 hour"
        when 1.hours..3.hours then "3 hours"
        when 3.hours..6.hours then "6 hours"
        when 6.hours..12.hours then "12 hours"
        when 12.hours..1.days then "1 day"
        when 1.days..3.days then "3 days"
        when 3.days..1.week then "1 week"
        else "--"
      end
    else
      "--"
    end
  end
  
  def online_opacity
    last_time_online, now = read_attribute(:last_action), Time.now
    if last_time_online
      case (now - last_time_online)
        when 0.minutes..5.minutes then 1.0
        when 5.minutes..10.minutes then 0.9
        when 10.minutes..30.minutes then 0.8
        when 30.minutes..1.hours then 0.7
        when 1.hours..3.hours then 0.6
        when 3.hours..6.hours then 0.5
        when 6.hours..12.hours then 0.4
        when 12.hours..1.days then 0.3
        when 1.days..3.days then 0.2
        when 3.days..1.week then 0.1
        else 0
      end
    else
      0
    end
  end

  def online_recently
    online_within(10.minutes)
  end
  
  def online_within(length_of_time)
    last_time_online = read_attribute(:last_action)
    last_time_online > Time.now - length_of_time unless last_time_online.nil?
  end
  
  # Check a portfolio has some images
  def has_images_in_portfolios?
    images = 0
    portfolios.each do |p|
      if p.has_images?
        images += 1
      end
    end
    images > 0 ? true : false
  end
  
  def total_portfolios
    count = 0
    portfolios.each do |p|
      if p.has_images?
        count += 1
      end
    end
    count
  end
  
  def example_image
    if self.example_id
      if Image.exists?(self.example_id)
        Image.find(self.example_id)
      elsif self.portfolios.length && self.portfolios.first.images.length
        self.portfolios.first.images.first
      else
        return nil
      end
    else
      return nil
    end
    
    self.example_id && Image.exists?(self.example_id) ? Image.find(self.example_id) : nil
  end
  
  # Class Methods
  class << self
    
    # Find an active user from their website
    def find_active_website(website)
      find(:first, :conditions => ["website = ? and status = ?", website, "Subscribed"])
    end
    
    # Find an active user by username
    def find_active_user(user)
      find(:first, :conditions => ["user = ? and status = ?", user, "Subscribed"])
    end
    
    # Return all of the users online within a certain time interval ago from now
    def online_within(length_of_time)
      find(:all, :conditions => ["last_action > ?", Time.now - length_of_time], :order => "last_action DESC")
    end
    
    def find_newer_user_than(user)
      find(:first, :conditions => ["id > ?", user.id], :order => "id ASC")
    end
    
    def find_older_user_than(user)
      find(:first, :conditions => ["id < ?", user.id], :order => "id DESC")
    end
    
  end
  
  protected
  
  def create_info
    build_info
  end
  
end
