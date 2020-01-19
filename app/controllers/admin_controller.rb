class AdminController < ApplicationController
  
  layout "admin"
  
  before_filter :login_required, :except => [:index, :process_login, :process_logout]
  
  caches_action :browse, :cache_path => "admin/browse"
  caches_action :profit_report, :cache_path => "admin/profit_report"
  caches_action :user, :cache_path => :user_cache_path.to_proc
  
  # mabe it would be easier to use :except ?
  cache_sweeper :admin_sweeper, :only => [
    :update_user, :update_user_analytics, :create_user, :delete_user, :post_news,
    :update_interview, :destroy_interview, :interview_add_image, :interview_remove_image, :interview_image_reorder, :interview_set_photographer, :interview_reorder,
    :example_create, :example_remove, :example_update, :example_add_image, :example_reorder
  ]

  def index
   # if !session[:user].nil? && session[:user].admin == true
   #    redirect_to :action => "browse"
   # end
   redirect_to :action => "browse" if logged_in? && current_user.admin?
  end
  
  def process_login
    user = params['user'].to_s
    pass = params['pass'].to_s
    # user = User.authenticate(user, pass)
    self.current_user = User.authenticate(user, pass)
    
    # try just redirecting here instead of doing it manually... those pages should do the check with the before_filter
    if logged_in?
      redirect_to :action => "browse"
    elsif logged_in? && !current_user.admin?
      redirect_to :action => "index", :error => "#{user.user} is not an admin"
    else
      redirect_to :action => "index", :error => "Invalid username/password"
    end
    # if user == nil
    #   redirect_to :action => "index", :error => "Invalid username/password"
    # elsif user.admin == false
    #   redirect_to :action => "index", :error => "#{user.user} is not an admin"
    # else
    #   session[:user] = user
    #   session.model.user_id = session[:user].id
    #   redirect_to :action => "browse"
    # end
  end
  
  def process_logout
    reset_session
    redirect_to :action => "index"
  end
  
  def browse
    # if session[:user].nil? or session[:user].admin == false
    #   redirect_to :action => "index"
    # end
  end
  
  def user
    # if session[:user].nil? or session[:user].admin == false
    #   redirect_to :action => "index"
    # end
    
    if params['id'] == nil
      redirect_to :action => "browse", :error => "Invalid user id.  Please select a user."
    else
      @user = User.find(params['id'])
      @newer_user = User.find_newer_user_than(@user)
      @older_user = User.find_older_user_than(@user)
    end
  end
  
  def user_portfolios
    u = User.find(params[:user_id])
    render :json => {:portfolios => u.portfolios.collect { |p| {:title => p.title, :id => p.id} }}
  end
  
  def user_portfolio
    p = Portfolio.find(params[:portfolio_id])
    render :json => {:images => p.images.collect { |i| {:id => i.id, :image => @template.s3_photo(i.id, 'thumb')} }}
  end
  
  def add_user
    # if session[:user].nil? or session[:user].admin == false
    #   redirect_to :action => "index"
    # end
  end
  
  def announce
    # if session[:user].nil? or session[:user].admin == false
    #   redirect_to :action => "index"
    # end
  end
  
  def profit_report
    redirect_to :action => :browse unless current_user.user == "cilphex"
  end
  
  def activity
    @recent_users = User.online_within(10.minutes)
    @recentImages = Image.find(:all, :order => "id DESC", :limit => 5, :conditions => 'portfolio_id IS NOT NULL')
  end
  
  def interviews
    @interviews = Interview.find(:all, :order => "position ASC, id DESC")
  end
  
  def interview
    @interview = Interview.exists?(params[:id]) ? Interview.find(params[:id]) : nil
  end

  def update_interview
    if params[:id].empty?
      @interview = Interview.create(
        :interviewer => params[:interviewer],
        :interviewee => params[:interviewee],
        :url         => params[:url],
        :link        => params[:link],
        :caption     => params[:caption],
        :body        => params[:body],
        :bio         => params[:bio],
        :enabled     => params[:enabled],
        :created     => Time.now,
        :last_edit   => Time.now
      )
    else
      @interview = Interview.find(params[:id])
      @interview.interviewer = params[:interviewer].to_s
      @interview.interviewee = params[:interviewee].to_s
      @interview.url = params[:url].to_s
      @interview.link = params[:link].to_s
      @interview.caption = params[:caption].to_s
      @interview.body = params[:body].to_s
      @interview.bio = params[:bio].to_s
      @interview.enabled = params[:enabled]
      @interview.last_edit = Time.now
      @interview.save
    end
    render :json => {:success => 1, :interview_id => @interview.id}
  end
  
  def destroy_interview
    i = Interview.find(params[:id])
    i.images.each do |image|
      image.delete_s3
      image.destroy
    end
    i.destroy
    render :json => {:success => 1}
  end
  
  def interview_add_image
    if params[:tmp_file].original_filename[-4..-1].downcase == '.jpg'
      interview = Interview.find(params[:interview_id])
      @image = Image.create(
        :interview_id => params[:interview_id],
        :description => params[:description],
        :uploaded => Time.now,
        :position => interview.images.length + 1
      )
      @image.file = params[:tmp_file]
      render :text => "<script>window.parent.Interview.addImage_cb(true,#{@image.id},'#{@template.s3_photo(@image.id, 'thumb')}');</script>"
    else
      render :text => "<script>window.parent.Interview.addImage_cb(false);</script>"
    end
  end
  
  def interview_remove_image
    @interview = Interview.find(params[:id])
    @image = Image.find(params[:image_id])
    if @interview.photographer_picid = @image.id
      @interview.photographer_picid = 0
      @interview.save
    end
    @image.delete_s3
    Image.destroy(params[:image_id])
    render :json => {:success => 1}
  end
  
  def interview_image_reorder
    image_ids = params[:images]
    image_ids.each_with_index do |id, i|
      img = Image.find(id)
      img.position = i
      img.save
    end
    render :json => {:success => 1}
  end
  
  def interview_set_photographer
    @interview = Interview.find(params[:id])
    old_photographer_picid = @interview.photographer_picid
    if params[:image_id] == old_photographer_picid.to_s
      @interview.photographer_picid = 0
    else
      @interview.photographer_picid = params[:image_id]
    end
    @interview.save
    render :json => {:success => 1, :old_photographer_picid => old_photographer_picid}
  end
  
  def interview_reorder
    interview_ids = params[:interviews]
    interview_ids.each_with_index do |id, i|
      e = Interview.find(id)
      e.position = i
      e.save
    end
    render :json => {:success => 1}
  end
  
  def examples
    @examples = Example.find(:all, :order => 'position ASC')
    @users = User.find(:all, :conditions => ['status != "Suspended" AND subscription > 0'], :order => 'id DESC');
  end
  
  def example_create
    @example = Example.create(
      :user_id => params[:user_id]
    )
    @users = User.find(:all, :conditions => ['status != "Suspended" AND subscription > 0'], :order => 'id DESC');
    render :partial => 'example' # varialble 'example' in _example.rhtml is auto-filled in
  end
  
  def example_remove
    e = Example.find(params[:example_id])
    if e.image
      e.image.delete_s3
      e.image.destroy
    end
    e.destroy
    render :json => {:success => 1}
  end
  
  def example_update
    e = Example.find(params[:example_id])
    e.user_id = params[:user_id]
    e.category = params[:category]
    e.location = params[:location]
    e.quote = params[:quote]
    e.description = params[:description]
    e.enabled = params[:enabled]
    e.name = params[:name]
    if e.save
      render :json => {:success => 1}
    else
      render :json => {:success => 0}
    end
  end
  
  def example_add_image
    e = Example.find(params[:example_id])
    if e.image
      e.image.delete_s3
      e.image.destroy
    end
    if params[:tmp_file].original_filename[-4..-1].downcase == '.jpg'
      @image = Image.create(
        :example_id => params[:example_id],
        :uploaded => Time.now,
        :description => 'Example'
      )
      @image.file = params[:tmp_file]
      render :text => "<script>window.parent.Example.addImage_cb(true,#{params[:example_id]},'#{@template.s3_photo(@image.id, 'student')}');</script>"
    else
      render :text => "<script>window.parent.Example.addImage_cb(false);</script>"
    end
  end
  
  def example_reorder
    example_ids = params[:examples]
    example_ids.each_with_index do |id, i|
      e = Example.find(id)
      e.position = i
      e.save
    end
    render :json => {:success => 1}
  end
  
  def controls
    @u_status = Server.updating ? 'Down' : 'Up'
  end
  
  def toggle_update_status
    Server.toggle_status
    render :text => '{status: ' + (Server.updating ? "'Down'" : "'Up'") + '}'
  end
  
  def stats
    @scale = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    @max_signups = User.find_by_sql("SELECT MAX(c) FROM (SELECT COUNT(MONTH(signup)) AS c FROM users GROUP BY MONTH(signup)) AS heynow").first["MAX(c)"]
    @signups_per_month = User.find_by_sql("SELECT MONTHNAME(signup) as name, YEAR(signup) as year, COUNT(MONTH(signup)) as signups FROM users GROUP BY MONTH(signup) ORDER BY signup ASC")
    @signups_graph_string, @signups_label_string = '', ''
    @signups_per_month.each do |month|
      @signups_graph_string += @scale[((month.signups.to_f / @max_signups.to_f) * @scale.length).ceil - 1, 1]
      @signups_label_string += '|' + month.name[0,3]
    end
  end
  
  def user_lookup
    if !params['status'].nil?
      @results = User.find(:all, :order => "id DESC", :conditions => {:status => params['status']})
    elsif !params['ppm'].nil? && params['ppm'].to_i == 99
      @results = User.find(:all, :order => "id DESC", :conditions => "subscription != 0 AND subscription != 13 AND subscription != 19 AND subscription != 34 AND status != 'Suspended'")
    elsif !params['ppm'].nil?
      @results = User.find(:all, :order => "id DESC", :conditions => {:subscription => params['ppm']})
    else
      @phrase = (request.raw_post || request.query_string).gsub(/%20/, ' ').gsub(/%40/, '@')
      if @phrase != ""
        @searchphrase = "%" + @phrase + "%"
        @results = User.find(:all, :order => "id DESC", :conditions => ["name LIKE ? OR website LIKE ? OR contactemail LIKE ?", @searchphrase, @searchphrase, @searchphrase])
      end
    end
    render :partial => "user_lookup"
  end
  
  def update_user
    @user = User.find(params['id'])
    @user.name = params['name']
    @user.website = params['domain']
    @user.user = params['username']
    @user.pass = params['password']
    @user.contactemail = params['contact']
    @user.status = params['user']['status']
    @user.grade = params['grade']
    @user.subscription = params['user']['subscription']
    if @user.save
      userstatus = '<span class="success"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      userstatus = '<span class="error">Could not save</span>'
    end
    redirect_to :action => "user", :id => params['id'], :userstatus => userstatus
  end
  
  def update_user_analytics
    @user = User.find(params['id'])
    @user.info.analytics = params['googleAnalytics']
    if @user.info.save
      userstatus = '<span class="success"><b>Analytics saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      userstatus = '<span class="error">Could not save analytics</span>'
    end
    render :text => userstatus
  end
  
  def create_user
    u = User.create(
      :user         => params['username'],
      :pass         => params['username'].crypt(Time.now.to_s[17,2])[0,6].gsub(/[\.\/]/, "a"),
      :signup       => Time.now,
      :name         => params['name'],
      :website      => params['domain'],
      :contactemail => params['contact'],
      :directory    => params['username'].crypt(Time.now.to_s[17,2]).gsub(/[\.\/]/, "a"),
      :grade        => params['grade'],
      :last_action  => Time.now
    )
    
    # If this line was commented out earlier for a reason, please let Craig know.
    # Until then, it's back.
    # Moved to filter in User model
    # Info.create(:user_id => u.id)
    
    redirect_to :action => "user", :id => u.id
  end
   
  def delete_user
    u = User.find(params['id'])
    u.portfolios.each do |p|
      p.images.each do |i|
        i.delete_s3
        Image.destroy(i.id)
      end
      s3_deletefile("portfolio_audio" + p.id.to_s + ".mp3")
      p.destroy
    end
    # the following might not work, but it doesn't error
    s3_deletefile("splash<%= u.id %>.jpg")
    s3_deletefile("banner<%= u.id %>.jpg")
    s3_deletefile("resume<%= u.id %>.pdf")
    s3_deletefile("audio<%= u.id %>.mp3")
    s3_deletefile("favicon<%= u.id %>.ico")
    s3_deletefile("biopic<%= u.id %>.jpg")
    u.info.destroy
    u.destroy
    redirect_to :action => "browse"
  end
  
  def check_user
    render :text => '{available: ' + (User.find_by_user(params['username']) ? '0' : '1') + '}'
  end
  
  def send_welcome_email
    u = User.find(params['id'])
    comment = Comment.new do |c|
      c.recipient = u.contactemail
      c.body = "#{u.website}|#{u.user}|#{u.pass}"
    end
    comment.save
    u.status = "Subscribed"
    u.save
    Mailer::deliver_welcome_email(comment)
    userstatus = '<span style="font-style: italic; color: #00BB00;"><b>Welcome email sent</b></span>'
    redirect_to :action => "user", :id => params['id'], :userstatus => userstatus
  end
  
  def recent_images
    imageInfo = ''
    Image.find(:all, :order => "id DESC", :limit => 5).each do |i|
      imageInfo += i.id.to_s + "*" + i.portfolio.user.id.to_s + "*" + i.portfolio.user.name.to_s + "*" + i.uploaded.strftime("%I:%M %p, %A").to_s + "|"
    end
    render :update do |page|
      page.recent_images.update(imageInfo)
    end
  end
  
  # if you add methods for editing news posts later, be sure to add them to the cache sweeper up top
  def post_news
    a = Announcement.create(
      # :user_id => session[:user].id,
      :user_id => current_user.id,
      :title => params['title'],
      :body => params['body'],
      :posted => Time.now
    )
    if a
      render :text => '<div class="post"><a href="#" conclick="$(\'post_' + a.id.to_s + '\').toggle ();">' + a.title + '</a>&nbsp;&nbsp;|&nbsp;&nbsp;Just now</div>' +
        '<div id="post_' + a.id.to_s + '" class="post_body" style="display: none;">' + a.body + '</div>'
    else
      render :text => '<div class="post">Post FAILED.</div>'
    end
  end
  
  #def online_users
  #  render :partial => 'online_users'
  #end
  
  # Delete a file from S3, if it's there.
  def s3_deletefile(filename)
    #AWS::S3::S3Object.delete filename, QBUCKET.to_s if AWS::S3::S3Object.exists? filename, QBUCKET.to_s
    AWS::S3::S3Object.delete filename, IMAGES_BUCKET.to_s if AWS::S3::S3Object.exists? filename, IMAGES_BUCKET.to_s
  end
  
  def authorized?
    logged_in? && current_user.admin?
  end
  
  def access_denied
    redirect_to :action => "index"
  end
  
  def user_cache_path
    "admin/user.#{params['id']}"
  end
  
end
