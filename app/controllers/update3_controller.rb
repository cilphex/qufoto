class Update3Controller < ApplicationController
  
  
  before_filter :check_server_status, :except => [:maintenance]
  # before_filter :check_server_status_ajax
  before_filter :login_required, :except => [:index, :maintenance]
  before_filter :update_last_action
  before_filter :browser_detect
  
  def check_server_status
    redirect_to :action => "maintenance" if Server.updating && !params[:ajax]
  end

  def check_server_status_ajax
    if Server.updating
      render :json => { :status => -1 }
    end
  end
  
  def update_last_action
    current_user.update_last_action if logged_in?
  end

  def browser_detect
    user_agent = request.env['HTTP_USER_AGENT'].downcase
    @supported = true
    @browser ||= begin
      if user_agent.index('msie')
        @supported = false
        'Internet Explorer'
      elsif user_agent.index('chrome/')
        'Google Chrome'
      elsif user_agent.index('applewebkit/')
        'Apple Safari'
      elsif user_agent.index('gecko/') || user_agent.index('mozilla/')
        'Mozilla Firefox'
      else
        @supported = false
        'unsupported'
      end
    end
  end
  
  def index
    #@section = 'index'
    #@body_class = 'signup'
    @section = 'signup'
    if request.env['HTTP_USER_AGENT'].downcase.index(/msie ([1-6])/)
      redirect_to :action => "browsers"
    elsif logged_in?
      redirect_to :action => "portfolios"
    end
  end
  
  # ajax
  def login
    user = params[:user].to_s
    pass = params[:pass].to_s
    self.current_user = User.authenticate(user, pass)
    render :json => {:success => logged_in?, :maintenance => Server.updating}
  end
  
  # ajax - recover password
  def password
    unless (u = (User.find_by_user(params[:user_email]) || User.find_by_contactemail(params[:user_email]))).nil?
      comment = Comment.new do |c|
        c.recipient = u.contactemail
        c.body = "Username: #{u.user}\nPassword: #{u.pass}"
      end
      comment.save
      Mailer::deliver_password_message(comment)
      render :json => {:success => 1, :email => u.contactemail}
    else
      render :json => {:success => 0}
    end
  end
  
  def logout
    reset_session
    redirect_to :action => :index
  end
  
  def maintenance
    redirect_to :action => :index if !Server.updating
    @section = 'maintenance'
    @hide_navigation = true
  end
  
  # Portfolios ==========================================================================
  
  def portfolios
    @section = 'portfolios'
    @portfolios = Portfolio.find_all_by_user_id(current_user.id, :order => 'position ASC')
  end
  
  def portfolio_create
    title_param = params[:title].to_s
    title = title_param.empty? ? 'Untitled' : title_param.to_s
    portfolio = Portfolio.create(:user_id => current_user.id, :title => title)
    render :json => {
      :success => 0,
      :id => portfolio.id,
      :partial => render_to_string(:partial => 'portfolio_row', :locals => {:p => portfolio})
    }
  end

  def portfolio_remove
    p = Portfolio.find(params['id'])
    p.images.each do |image|
      image.delete_s3
      image.destroy
    end
    p.destroy
    render :json => {
      :success => 0,
      :id => p.id
    }
  end

  def portfolio_visibility
    p = Portfolio.find(params['id'])
    p.hidden = !p.hidden
    p.save
    render :json => {
      :success => 0,
      :id => p.id,
      :hidden => p.hidden
    }
  end

  def portfolio_order
    success = 0
    portfolios = params[:portfolios]
    portfolios.length.times do |pos|
      p = Portfolio.find(portfolios[pos])
      p.position = pos
      if !p.save
        success = 1
      end
    end
    render :json => {
      :success => success
    }
  end

  def portfolio_rename
    p = Portfolio.find(params['id'])
    p.title = params['title']
    p.save
    render :json => {
      :success => 0,
      :id => p.id,
      :title => p.title
    }
  end

  def portfolio_privacy
    p = Portfolio.find(params['id'])
    p.private = params['privacy']
    p.password = params['password']
    p.save
    render :json => {
      :success => 0,
      :id => p.id,
      :private => p.private
    }
  end

  def portfolio_multimedia
    p = Portfolio.find(params['id'])
    p.slideshow = params['multimedia']
    p.save
    render :json => {
      :success => 0,
      :id => p.id
    }
  end

  def portfolio_attach_audio
    if params['tmp_file'].original_filename =~ /\.mp3$/
      s3_updatefile "portfolio_audio" + params['id'] + ".mp3", params['tmp_file'].read
      Portfolio.find(params['id']).add_audio
      render :text => '<script type="text/javascript">window.parent.Portfolio.audioSuccess(' + params['id'] + ');</script>'
    else
      render :text => '<script type="text/javascript">window.parent.Portfolio.audioError(' + params['id'] + ');</script>'
    end
  end

  def portfolio_delete_audio
    s3_deletefile "portfolio_audio" + params['id'].to_s + ".mp3"
    p = Portfolio.find(params['id'])
    p.remove_audio
    render :json => {
      :success => 0,
      :id => p.id
    }
  end
  
  # Images =========================================================================

  def image_thumbs
    @section = 'images'
  end

  def image_order
    success = 0
    images = params[:images]
    images.length.times do |pos|
      i = Image.find(images[pos])
      i.position = pos
      if !i.save
        success = 1
      end
    end
    render :json => {
      :success => success
    }
  end

  def image_remove
    i = Image.find(params['id'])
    i.delete_s3
    Image.destroy(i.id)
    Portfolio.update_counters i.portfolio_id, :images_count => -1
    render :json => {
      :success => 0
    }
  end

  def image_portfolio_partial
    p = Portfolio.find(params['id'])
    type = 'image_' + params['type'].to_s
    render :partial => type, :locals => { :p => p }
  end

  def image_detail_partial
    i = Image.find(params['id'])
    render :partial => 'image_detail', :locals => { :image => i }
  end

  def image_update
    i = Image.find(params['id'])
    i.title = params['title'].gsub(/&/, 'and')
    i.description = params['description'].gsub(/&/, 'and')
    i.save
    render :json => {
      :success => 0,
      :id => i.id
    }
  end

  def image_portfolio
    i = Image.find(params['image_id'])
    Portfolio.update_counters i.portfolio_id, :images_count => -1
    i.portfolio_id = params['portfolio_id'].to_i
    i.save
    Portfolio.update_counters i.portfolio_id, :images_count => 1
    render :json => {
      :success => 0,
      :image_id => i.id
    }
  end
  
  def image_list
    @section = 'images'
  end
  
  def image_upload
    @section = 'images'
  end

  def image_upload_process
    title       = params['image_title']
    description = params['image_description']
    portfolio   = params['image_portfolio']
    file        = params['image_file']
    rollover    = params['image_rollover']

    if file.blank?
      render :partial => 'image_uploaded', :locals => { :success => 1 }

    elsif file.original_filename[-4..-1].downcase == '.jpg'
      image = Image.new do |i|
        i.title = title
        i.description = description
        i.portfolio_id = portfolio
        i.uploaded = Time.now
      end
      if image.save then
        # file= is a function that performs the s3 upload
        image.file = file
        if current_user.grade == 'Pro' and !rollover.nil? and !rollover.blank? and rollover.original_filename[-4..-1].downcase == '.jpg'
          image.fileRollover = rollover
          image.rollover = true
        end
        image.save
      end
      render :partial => 'image_uploaded', :locals => { :success => 0, :uploaded_image => image }

    else
      render :partial => 'image_uploaded', :locals => { :success => 2 }
    end
  end
  
  # Layout =========================================================================
  
  def layout_template
    @section = 'layout'
  end

  def layout_colors
    @section = 'layout'
  end
  
  def layout_banner
    @section = 'layout'
  end

  def layout_banner_process
    if params['tmp_file'].original_filename =~ /\.jpg$/i
      pic = Magick::Image.from_blob(params['tmp_file'].read).first
      pic.resize_to_fit!(920, 100) if pic.columns > 920 or pic.rows > 100
      s3_updatefile "banner" + current_user.id.to_s + ".jpg", pic.to_blob {self.quality = 90}
      current_user.info.add_banner
      render :partial => 'banner_uploaded', :locals => { :status => 0 }
    else
      render :partial => 'banner_uploaded', :locals => { :status => 1 }
    end
  end

  def layout_banner_delete
    if s3_deletefile "banner" + current_user.id.to_s + ".jpg"
      current_user.info.remove_splash
      render :json => { :status => 0 }
    else
      render :json => { :status => 1 }
    end
  end

  def layout_banner_visibility
    current_user.info.bannerdisplay = !current_user.info.bannerdisplay
    current_user.info.save
    render :json => {
      :status => 0,
      :visible => current_user.info.bannerdisplay
    }
  end
  
  def layout_splash
    @section = 'layout'
  end

  def layout_splash_process
    if params['tmp_file'].original_filename =~ /\.jpg$/i
      pic = Magick::Image.from_blob(params['tmp_file'].read).first
      pic.resize_to_fit!(900, 600) if pic.columns > 900 or pic.rows > 600
      s3_updatefile "splash" + current_user.id.to_s + ".jpg", pic.to_blob {self.quality = 90}
      current_user.info.add_splash
      render :partial => 'splash_uploaded', :locals => { :status => 0 }
    else
      render :partial => 'splash_uploaded', :locals => { :status => 1 }
    end
  end

  def layout_splash_delete
    if s3_deletefile "splash" + current_user.id.to_s + ".jpg"
      current_user.info.remove_splash
      render :json => { :status => 0 }
    else
      render :json => { :status => 1 }
    end
  end

  def layout_splash_visibility
    current_user.info.splashdisplay = !current_user.info.splashdisplay
    current_user.info.save
    render :json => {
      :status => 0,
      :visible => current_user.info.splashdisplay
    }
  end
  
  def layout_favicon
    @section = 'layout'
  end
  
  def layout_links
    @section = 'layout'
  end

  def layout_links_save
    fields1 = ['link_portfolios', 'link_multimedia', 'link_biography', 'link_contact', 'link_resume', 'link_clientaccess', 'link1', 'link2', 'link3']
    fields2 = ['link1_address', 'link2_address', 'link3_address']
    fields1.each do |f|
      current_user.info[f] = params[f].to_s.gsub(/&/, 'and')
    end
    fields2.each do |f|
      current_user.info[f] = params[f].to_s
    end
    current_user.info.save
    render :json => { :status => 0 }
  end
  
  def layout_status
    @section = 'layout'
  end

  def layout_status_save
    current_user.info.enabled = params['status'].to_s == "true" ? true : false
    if current_user.info.save
      render :json => { :status => 0, :enabled => current_user.info.enabled }
    else
      render :json => { :status => 1 }
    end
  end
  
  def layout_javascript
    @section = 'layout'
  end

  def layout_javascript_save
    current_user.info.analytics = params['javascript']
    if current_user.info.save
      render :json => { :status => 0 }
    else
      render :json => { :status => 1 }
    end
  end
  
  # Basic info =========================================================================
  
  def basic_info
    @section = 'basic'
    @info = current_user.info
  end

  def basic_info_save
    properties = ['name', 'email', 'title', 'toptext', 'description', 'keywords', 'verifyv1', 'contact_info']
    properties.each do |property|
      current_user.info[property] = params[property].gsub(/&/, 'and');
    end
    current_user.info.save
    render :json => { :success => 0 }
  end

  def basic_bio
    @section = 'basic'
  end
  
  def basic_bio_save
    current_user.info.biography = params['biography'].gsub(/&/, 'and')
    current_user.info.save
    render :json => {
      :status => 0
    }
  end

  def basic_bio_visibility
    current_user.info.biodisplay = !current_user.info.biodisplay
    current_user.info.save
    render :json => {
      :status => 0,
      :visible => current_user.info.biodisplay
    }
  end

  def basic_biopic_process
    if params['tmp_file'].original_filename[-4..-1].downcase == '.jpg'
      pic = Magick::Image.from_blob(params['tmp_file'].read).first
      pic.resize_to_fit!(300, 460) if pic.columns > 300 or pic.rows > 460
      s3_updatefile 'biopic' + current_user.id.to_s + '.jpg', pic.to_blob { self.quality = 90 }
      current_user.info.add_biopic
      render :partial => 'biopic_uploaded', :locals => { :status => 0 }
    else
      render :partial => 'biopic_uploaded', :locals => { :status => 1 }
    end
  end

  def basic_biopic_visibility
    current_user.info.biopicdisplay = !current_user.info.biopicdisplay
    current_user.info.save
    render :json => {
      :status => 0,
      :visible => current_user.info.biopicdisplay
    }
  end

  def basic_resume
    @section = 'basic'
  end

  def basic_resume_process
    if params['tmp_file'].original_filename =~ /\.pdf$/
      s3_updatefile "resume" + current_user.id.to_s + ".pdf", params['tmp_file'].read
      current_user.info.add_resume
      render :partial => 'resume_uploaded', :locals => { :status => 0 }
    else
      render :partial => 'resume_uploaded', :locals => { :status => 1 }
    end
  end

  def basic_resume_delete
    if s3_deletefile 'resume' + current_user.id.to_s + '.pdf'
      current_user.info.remove_resume
      render :json => { :status => 0 }
    else
      render :json => { :status => 1 }
    end
  end

  def basic_resume_visibility
    current_user.info.resumedisplay = !current_user.info.resumedisplay
    current_user.info.save
    render :json => {
      :status => 0,
      :visible => current_user.info.resumedisplay
    }
  end
  
  # Messages =========================================================================
  
  def messages
    @section = 'messages'
  end

  def message_remove
    Comment.destroy(params['id'])
    render :json => {
      :success => 0
    }
  end

  # Settings =========================================================================
  
  def settings_general
    @section = 'settings'
  end

  def settings_password
    @section = 'settings'
  end

  def settings_password_save
    pass1 = params['password1'].to_s;
    pass2 = params['password2'].to_s;
    pass3 = params['password3'].to_s;
    if pass1 != current_user.pass
      status = 1                          # incorrect password
    elsif pass2.blank? || pass3.blank?
      status = 2                          # passwords are empty
    elsif pass2 != pass3
      status = 3                          # passwords don't match
    else
      current_user.pass = pass2;
      current_user.save
      status = 0
    end
    render :json => { :status => status }
  end

  # Sharing =========================================================================

  def sharing
    @section = 'sharing'
  end
  
  # Community ===========================================================================
  
  # Maybe this should be public - that'd be cool
  def community
    @section = 'community'
  end
  
  # /Community ==========================================================================
  
  # Delete a file from S3, if it's there.
  def s3_deletefile(filename)
    #AWS::S3::S3Object.delete filename, QBUCKET.to_s if AWS::S3::S3Object.exists? filename, QBUCKET.to_s
    AWS::S3::S3Object.delete filename, IMAGES_BUCKET.to_s if AWS::S3::S3Object.exists? filename, IMAGES_BUCKET.to_s
  end
  
  # Update a file in S3.  Add if it doesn't exist.
  def s3_updatefile(filename, filedata)
    s3_deletefile filename
    #AWS::S3::S3Object.store filename, filedata, QBUCKET.to_s, :access => :public_read
    AWS::S3::S3Object.store filename, filedata, IMAGES_BUCKET.to_s, :access => :public_read
  end

  protected
  
  # overwrite authorized in lib/authenticated_system.rb
  def authorized
    logged_in? and current_user.status != 'Suspended'
  end
  
  def login_required
    authorized? || params[:ajax] || access_denied
  end
  
  # overwrite access_denied in lib/authenticated_system.rb
  def access_denied
    redirect_to :controller => :update3
  end
  
end