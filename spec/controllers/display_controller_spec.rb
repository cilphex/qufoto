require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DisplayController do
  
  describe "Index" do
  
    before(:each) do
      @user = mock(User)
      @info = mock(Info)
      Info.stub!(:find).and_return(@info)
      @user.stub!(:info).and_return(@info)
      @info.stub!(:enabled?).and_return(true)
      @user.stub!(:has_images_in_portfolios?).and_return(true)
      @info.stub!(:splashdisplay?).and_return(true)
    end
  
    describe "GET :index with user" do
    
      before(:each) do
        User.stub!(:find).and_return(@user)
      end
    
      it "should find user" do
        User.should_receive(:find_by_user).and_return(@user)
        get :index, :user => "lacey"
      end
    
      it "should be success" do
        get :index, :user => "lacey"
        response.should be_success
      end
    
      it "should render splash" do
        get :index, :user => "lacey"
        response.should render_template("display/splash")
      end
    
      it "should render displayLite template" do
        get :index, :user => "lacey", :t => 1, :enter => true
        response.should render_template("display/displayLite")
      end
    
      it "should render displayPro template" do
        get :index, :user => "lacey", :t => 2, :enter => true
        response.should render_template("display/displayPro")
      end
    
      it "should render displayWide template" do
        get :index, :user => "lacey", :t => 3, :enter => true
        response.should render_template("display/displayWide")
      end
    
    end
  
    describe "GET :index with server" do
    
      before(:each) do
        request.env['HTTP_X_FORWARDED_HOST'] = "laceyannphotography.com"
        User.stub!(:find_active_website).and_return(@user)
      end

      it "should find website" do
        User.should_receive(:find_active_website).with("laceyannphotography.com").and_return(@user)
        get :index
      end
    
    end
    
    describe "GET :index, site disabled" do
      
      before(:each) do
        @info.stub!(:enabled?).and_return(false)
      end
      
      it "should render maintenance page" do
        @info.should_receive(:enabled?).and_return(false)
        get :index, :user => "lacey"
        response.should render_template("display/maintenance")
      end
      
    end
  
  end
  
  describe "Flash info" do
    before(:each) do
      @user = mock(User)
    end
    describe "GET :flash_info with user" do
      it "should render flash info" do
        get :flash_info, :user => "lacey"
        response.should render_template("flash_info")
      end
    end
    describe "GET :flash_info with server" do
      before(:each) do
        request.env['HTTP_X_FORWARDED_HOST'] = "laceyannphotography.com"
        User.stub!(:find_active_website).and_return(@user)
      end
      it "should find website" do
        User.should_receive(:find_active_website).with("laceyannphotography.com").and_return(@user)
        get :flash_info
      end
      it "should render flash info" do
        get :flash_info
        response.should render_template("flash_info")
      end
    end
    describe "GET :flash_info with no user or server" do
      before(:each) do
        request.env['HTTP_X_FORWARDED_HOST'] = "test.com"
      end
      it "should render text - Website not found" do
        get :flash_info
        response.should have_text("Website not found")
      end
    end
  end

end
