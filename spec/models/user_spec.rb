require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  
  fixtures :users
  
  describe "methods on user class" do
  
    it "should find an active user by username" do
      user = User.find_active_user(users(:lacey).user)
      user.should eql(users(:lacey))
    end
  
    it "should find an active user by website" do
      user = User.find_active_website(users(:lacey).website)
      user.should eql(users(:lacey))
    end
  
  end
  
end
