class Example < ActiveRecord::Base
  
  belongs_to :user
  has_one :image
  
end
