class DisplayController < ApplicationController
  
  # All pages are different.  No layout used here.
  
  before_filter :find_server
  before_filter :show_splash, :only => [:index]
  
  caches_action :index,       :cache_path => :index_cache_path.to_proc
  caches_action :phone,       :cache_path => :phone_cache_path.to_proc
  caches_action :tablet,      :cache_path => :tablet_cache_path.to_proc
  caches_action :splash,      :cache_path => :splash_cache_path.to_proc
  caches_action :flash_info,  :cache_path => :flash_info_cache_path.to_proc

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
    
  def index
    if @user.info.enabled? && @user.has_images_in_portfolios?
      case @user.info.template
        when 0, 1
          render :template => 'display/display_lite'
        when 2
          render :template => 'display/display_pro'
        when 3, 4
          render :template => 'display/display_wide'
      end
    else
      render :template => 'display/maintenance'
    end
  end
  
  def phone
    @user_data = @user.to_json :include => {
      :info => {},
      :portfolios => {
        :only => [:id],
        :order => 'position ASC',
        :conditions => ['id != ?', 1],
        :include => {
          :images => {
            :only => [:id, :title, :description, :position],
            :order => 'position ASC'
          }
        }
      }
    }
    @imgserver = QBUCKET
    render :template => 'display/phone'
  end
  
  def tablet
    @user_data = @user.to_json :include => {
      :info => {},
      :portfolios => {
        :only => [:id],
        :order => 'position ASC',
        :conditions => ['id != ?', 1],
        :include => {
          :images => {
            :only => [:id, :title, :description, :position],
            :order => 'position ASC'
          }
        }
      }
    }
    @imgserver = QBUCKET
    render :template => 'display/tablet'
  end
  
  def splash
  end
  
  def flash_info
  end
  
  def send_message
    comment = Comment.new do |c|
      c.user_id   = @user.id
      c.recipient = @user.info.email
      c.sender    = params['messageName']
      c.replyTo   = params['messageEmail']
      c.body      = params['messageText']
    end
    comment.save
    begin
      Mailer.deliver_message(comment)
      render :text => "&success=true"
    rescue Exception
      render :text => "&success=false"
    end
  end
  
  protected
  
  def find_server
    if params["user"]
      @user = User.find_active_user(params["user"])
    else
      if ENV['RAILS_ENV'] == 'development'
        server = request.env['SERVER_NAME'].gsub(/^www\./, '')
      else
        server = request.env['HTTP_X_FORWARDED_HOST'].gsub(/^www\./, '')
      end
      @user = User.find_active_website(server)
    end
    redirect_to "http://qufoto.com" if @user.nil?
  end
  
  def phone?
    params[:phone] or request.user_agent =~ /Mobile|webOS/i
  end
  
  def tablet?
    params[:tablet] or request.user_agent =~ /iPad/i
  end
  
  def show_splash
    if tablet?
       redirect_to :action => :tablet
    elsif phone?
      redirect_to :action => :phone
    elsif @user && @user.info.splash? && @user.info.splashdisplay? && params['enter'].nil?
      # render :action => "splash" is only one page hit but renders splash each time without using the cache.
      # redirect_to :action => "splash" is two page hits (one for the redirect) but uses the cached splash page.      
      redirect_to :action => :splash
    end
  end
  
  %w{index phone tablet splash flash_info}.each do |page|
    define_method("#{page}_cache_path") do
      "display/#{page}.#{@user.id}"
    end
  end
  
end
