class UpdateController < ApplicationController
  
  session :off, :only => [:progress, :status]
  
  layout "update_2", :except => [:picker, :send_contact_admin, :edit_image, :update_image, :update_image_remote, :d_image, :progress, :status, :maintenance]
  
  before_filter :update_last_action
  
  before_filter :check_server_status, :except => [:index, :maintenance, :contact_admin, :send_contact_admin, :process_login, :process_logout, :request_pass, :progress, :status, :browsers]
  
  cache_sweeper :display_sweeper, :except => [ :index, :browsers, :portfolios, :layout, :upload, :progress, :status, :add_test, :images, :personal, :messages, :contact_admin,
                                                  :tips, :help, :process_login, :process_logout, :request_pass, :portfolio_select, :thumbnail_view, :list_view, :edit_images, :thumbnails, :send_contact_admin,
                                                  :manage_images, :picker, :edit_image_info_form, :edit_image, :test, :news, :show_partial, :s3_deletefile, :s3_updatefile, :delete_message ]
  
  def update_last_action
    current_user.update_last_action if logged_in?
  end
  
  def check_server_status
    Server.updating ? (redirect_to :action => "maintenance") : login_required
  end
  
  def index
    if request.env['HTTP_USER_AGENT'].downcase.index(/msie ([1-6])/)
      redirect_to :action => "browsers"
    elsif logged_in?
      redirect_to :action => "portfolios"
    end
  end

  def maintenance
    # Nothing here
  end
  
  def browsers
    @section = "browser error"
  end
  
  def portfolios
    @section = "portfolios"
  end
  
  def layout
    @section = "layout"
  end
  
  def upload
    @section = "upload"
    @upid = Time.now.to_i.to_s[-5..-1] + rand(100000).to_s
  end
  
  def upload2
    @section = "upload"
  end
  
  def progress
    render :update do |page|
      @status = Mongrel::Uploads.check(params[:upload_id])
      page.upload_progress.update(@status[:size], @status[:received]) if @status
    end
  end
  
  def status
    @status = Mongrel::Uploads.check(params[:upload_id])
    render :text => "#{@status[:size]}, #{@status[:received]}"
  end
  
  def add_test
    render :text => %(UPLOADED: #{params.inspect}.<script type="text/javascript">window.parent.UploadProgress.finish();</script>)
  end
  
  def images
    @section = "images"
  end
  
  def personal
    @section = "personal"
  end
  
  def messages
    @section = "messages"
  end
  
  def contact_admin
  end
  
  def send_contact_admin
    comment = Comment.new do |c|
      c.sender = current_user.name
      c.replyTo = current_user.contactemail
      c.body = params['body']
    end
    comment.save
    Mailer::deliver_comment(comment)
    render :text => "Your comment has been sent"
  end
  
  def tips
  end
  
  def help
  end

  def process_login
    user = params['user'].to_s
    pass = params['pass'].to_s
    self.current_user = User.authenticate(user, pass)
    # try just redirecting here instead of doing it manually... those pages should do the check with the before_filter
    if logged_in?
      redirect_to :action => "portfolios"
    else
      redirect_to :action => "index", :error => "Invalid username/password"
    end
  end
  
  def process_logout
    reset_session
    redirect_to :action => "index"
  end
  
  def request_pass
    unless (u = (User.find_by_user(params['useremail']) || User.find_by_contactemail(params['useremail']))).nil?
      comment = Comment.new do |c|
        c.recipient = u.contactemail
        c.body = "Username: #{u.user}\nPassword: #{u.pass}"
      end
      comment.save
      Mailer::deliver_password_message(comment)
      render :text => "A reminder email has been sent to #{u.contactemail}"
    else
      render :text => "The username or email address '#{params['useremail']}' was not found in our system"
    end
  end
  
  def delete_message
    render :text => '{deleted: ' + (Comment.destroy(params['message_id']) ? '1' : '0') + '}'
  end
  
  def add_portfolio
    if params['title'].to_s == ''
      render :partial => "portfolio_list", :error => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">The portfolio needs a title</span>'
    elsif params['title'].length > 30
      render :partial => "portfolio_list", :error => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">The portfolio title must be 30 characters or less</span>'
    else
      update_stat('zp3M6E5kNwjlkj9auOk3JbaWHvx', 'count')
      Portfolio.create(:user_id => current_user.id, :title => params['title'])
      render :partial => "portfolio_list"
    end
  end
  
  def delete_portfolio
    p = Portfolio.find(params['id'])
    p.images.each do |image|
      image.delete_s3
      image.destroy
    end
    p.destroy
    update_stat('cIRzQ1831EzSsIiv0lfPv5c1OQs', 'count')
    render :partial => "portfolio_list"
  end
  
  def rename_portfolio
    p = Portfolio.find(params['portfolio_id'])
    p.title = params['new_title']
    if p.save
      render :text => '{status: 1}'
    else
      render :text => '{status: 0}'
    end
  end
  
  def portfolio_visibility
    p = Portfolio.find(params['portfolio_id'])
    p.hidden = params['hidden']
    if p.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def portfolio_slideshow
    p = Portfolio.find(params['portfolio_id'])
    p.slideshow = params['slideshow']
    if p.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def portfolio_privacy
    p = Portfolio.find(params['portfolio_id'])
    p.private = params['privacy']
    p.password = params['password']
    if p.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def order_portfolios
    portfolios = params[:portfolio_list]
    portfolios.length.times do |pos|
      p = Portfolio.find(portfolios[pos])
      p.position = pos
      if !p.save
        render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
        return
      end
    end
    render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
  end

  def order_portfolio
    images = params[:sortableThumbs].nil? ? params[:listThumbs] : params[:sortableThumbs]
    images.length.times do |pos|
      i = Image.find(images[pos])
      i.position = pos
      i.save 
    end
    render :nothing => true
  end
  
  def update_times
    p = Portfolio.find(params['portfolio_id'])
    p.images.each do |i|
      i.duration = params["duration#{i.id}"].to_i
      if !i.save
        render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
        return
      end
    end
    render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
  end

  def portfolio_select
    render :partial => "portfolio_select"
  end
  
  def thumbnail_view
    render :partial => "image_order_thumbs"
  end
  
  def list_view
    render :partial => "image_order_list"
  end

  # deprecated.  replaced by following method
  def edit_images
    render :partial => "edit_image_info_thumbs"
  end
  
  def thumbnails
    render :partial => "thumbnails"
  end
  
  def manage_images
    render :partial => "manage_images_thumbs"
  end
  
  def picker
  end
  
  def update_website_status
    current_user.info.enabled = params['enabled'] == "true" ? true : false
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def update_javascript 
    current_user.info.analytics = params['javascript']
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def template_select
    current_user.info.template = params['template']
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def transition_select
    current_user.info.transition = params['transition']
    current_user.info.transitionspeed = params['transitionspeed'].to_s.to_i
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def update_arrowdisplay
    current_user.info.arrowdisplay = params['arrowdisplay'] == "true" ? true : false
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def update_arrows
    current_user.info.arrowsize = params['arrowsize']
    current_user.info.arrowcolor = params['arrowcolor']
    current_user.info.arrowalpha = params['arrowalpha']
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def update_colors
    current_user.info.bgcolor         = params['bgcolor']
    current_user.info.innerbgcolor    = params['innerbgcolor']
    current_user.info.textcolor       = params['textcolor']
    current_user.info.thumbbgcolor    = params['thumbbgcolor']
    current_user.info.highlightcolor  = params['highlightcolor']
    current_user.info.color5          = params['color5'] unless params['color5'].nil?
    current_user.info.innerbgalpha    = params['innerbgalpha'].to_s.to_i
    current_user.info.thumbbgalpha    = params['thumbbgalpha'].to_s.to_i
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def update_background_details
    current_user.info.bgtype      = params['bgtype'].to_s.to_i
    current_user.info.bgpos       = params['bgpos'].to_s.to_i
    current_user.info.bgrepeat    = params['bgrepeat'].to_s.to_i
    current_user.info.bggradient  = params['bggradient'].to_s.to_i
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def update_background_image
    if params['tmp_file'].original_filename =~ /\.jpg$/i
      s3_updatefile "background" + current_user.id.to_s + '.jpg', params['tmp_file'].read
      current_user.info.add_bgimage
      bgmessage = '<span style="font-style: italic; color: #00BB00;"><b>Uploaded</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      bgmessage = '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Image must be a .JPG</span>'
    end
    redirect_to :action => "layout", :page => "color_scheme", :message => bgmessage
  end  
  
  def audio_play
    current_user.info.audioplay = params['audioplay'] == "true" ? true : false
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def audio_loop
    current_user.info.audioloop = params['audioloop'] == "true" ? true : false
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def update_audio
    if params['tmp_file'].original_filename =~ /\.mp3$/
      s3_updatefile "audio" + current_user.id.to_s + ".mp3", params['tmp_file'].read
      current_user.info.add_audio
      audiomessage = '<span style="font-style: italic; color: #00BB00;"><b>Uploaded</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      audiomessage = '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Incorrect file format.  mp3 Only.</span>'
    end
    redirect_to :action => "layout", :page => "audio", :message => audiomessage
  end
  
  def attach_audio
    if params['tmp_file'].original_filename =~ /\.mp3$/
      s3_updatefile "portfolio_audio" + params['portfolio_id'] + ".mp3", params['tmp_file'].read
      Portfolio.find(params['portfolio_id']).add_audio
      render :text => '<script type="text/javascript">window.parent.audioSuccess(' + params['portfolio_id'] + ');</script>'
    else
      render :text => '<script type="text/javascript">window.parent.audioError(' + params['portfolio_id'] + ');</script>'
    end
  end
  
  def delete_audio
    if s3_deletefile "audio" + current_user.id.to_s + ".mp3"
      current_user.info.remove_audio
      audiomessage = '<span style="font-style: italic; color: #00BB00;"><b>Deleted</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      audiomessage = '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not be deleted</span>'
    end
    redirect_to :action => "layout", :page => "audio", :message => audiomessage
  end
  
  def delete_portfolio_audio
    if s3_deletefile "portfolio_audio" + params['portfolio_id'].to_s + ".mp3"
      current_user.portfolios.find(params['portfolio_id']).remove_audio
      render :text => '{status: 1}'
    else
      render :text => '{status: 0}'
    end
  end
  
  def update_banner
    if params['tmp_file'].original_filename =~ /\.jpg$/i
      pic = Magick::Image.from_blob(params['tmp_file'].read).first
      pic.resize_to_fit!(920, 100) if pic.columns > 920 or pic.rows > 100
      s3_updatefile "banner" + current_user.id.to_s + ".jpg", pic.to_blob {self.quality = 90}
      current_user.info.add_banner
      update_stat('JDN1p7k09O44jlvlVud5wOJGmh', 'count')
      bannermessage = '<span style="font-style: italic; color: #00BB00;"><b>Uploaded</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      bannermessage = '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Image must be a .JPG</span>'
    end
    redirect_to :action => "layout", :page => "banner", :message => bannermessage
  end
  
  def delete_banner
    if s3_deletefile "banner" + current_user.id.to_s + ".jpg"
      current_user.info.remove_banner
      update_stat('tQHX2OnxRt6pFms7TXc0LpxoQyO', 'count')
      bannermessage = '<span style="font-style: italic; color: #00BB00;"><b>Deleted</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      bannermessage = '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not be deleted</span>'
    end
    redirect_to :action => "layout", :page => "banner", :message => bannermessage
  end
  
  def banner_display
    current_user.info.bannerdisplay = params['bannerdisplay'] == "true" ? true : false
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def update_splash
    if params['tmp_file'].original_filename =~ /\.jpg$/i
      pic = Magick::Image.from_blob(params['tmp_file'].read).first
      pic.resize_to_fit!(900, 600) if pic.columns > 900 or pic.rows > 600
      s3_updatefile "splash" + current_user.id.to_s + ".jpg", pic.to_blob {self.quality = 90}
      current_user.info.add_splash
      update_stat('9kDnpyMy1WtTZcgqWtHHNlgZ905', 'count')
      splashmessage = '<span style="font-style: italic; color: #00BB00;"><b>Uploaded</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      splashmessage = '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Image must be a .JPG</span>'
    end
    redirect_to :action => "layout", :page => "splash", :message => splashmessage
  end
  
  def delete_splash
    if s3_deletefile "splash" + current_user.id.to_s + ".jpg"
      current_user.info.remove_splash
      update_stat('3mxTg7gA1tdr5Nbt8AYIl5aTu1W', 'count')
      splashmessage = '<span style="font-style: italic; color: #00BB00;"><b>Deleted</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      splashmessage = '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not be deleted</span>'
    end
    redirect_to :action => "layout", :page => "splash", :message => splashmessage
  end
  
  def splash_display
    current_user.info.splashdisplay = params['splashdisplay'] == "true" ? true : false
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def update_image
    image = Image.find(params['image_id'])
    Portfolio.update_counters image.portfolio_id, :images_count => -1 # kj: decrement old portfolio image_count 
    image.title = params['image']['title'].gsub(/&/, 'and')
    image.description = params['image']['description'].gsub(/&/, 'and')
    image.portfolio_id = params['portfolio_id']['first'].to_i     # for some reason, to_s.to_i works
    image.save
    Portfolio.update_counters image.portfolio_id, :images_count => 1 # kj : increment new portfolio image_count
    update_stat('gHW9lwQ4txuppjSP7SGjJI4Ri9G', 'count')
    render :text => '<script type="text/javascript">window.parent.editedImage (' + image.id.to_s + ', ' + image.portfolio_id.to_s + ');</script>'
  end
  
  def update_image_remote
    i = Image.find(params['image_id'])
    Portfolio.update_counters image.portfolio_id, :images_count => -1 # kj: decrement old portfolio image_count
    i.title = params['image']['title'].gsub(/&/, 'and')
    i.description = params['image']['description'].gsub(/&/, 'and')
    i.portfolio_id = params['portfolio_id']['first'].to_i     # for some reason, to_s.to_i works
    i.save
    Portfolio.update_counters image.portfolio_id, :images_count => 1 # kj : increment new portfolio image_count
    update_stat('gHW9lwQ4txuppjSP7SGjJI4Ri9G', 'count')
    render :nothing => true
  end
  
  def edit_image_info_form
    render :partial => "edit_image_info_form", :image_id => params["image_id"]
  end
  
  # need to add case that no first file is chosen.  try .blank? on .original_filename
  def add_image
    if params['image']['tmp_file'].original_filename[-4..-1].downcase == ".jpg"
      @image = Image.new do |i|
        i.title = params['image']['title'].gsub(/&/, 'and')
        i.description = params['image']['description'].gsub(/&/, 'and')
        i.portfolio_id = params['portfolio_id']['first'].to_i
        i.uploaded = Time.now
      end
      if @image.save then
        @image.file = params['image']['tmp_file']
        if rollover = (current_user.grade == "Pro" and params['image']['tmp_file_rollover'] and  params['image']['tmp_file_rollover'] != '' and params['image']['tmp_file_rollover'].original_filename[-4..-1].downcase == ".jpg")
          @image.fileRollover = params['image']['tmp_file_rollover']
          @image.rollover = true
        end
        @image.save
      end
      update_stat('edXkiaAoHsHIV4DF0knv3EKs1B5', 'count')
      #render :text => '<script type="text/javascript">window.parent.UploadProgress.finish();</script>'
      #render :text => '<script type="text/javascript">window.parent.showImage(\'' + @image.id.to_s + '\', ' + rollover.to_s + ');window.parent.UploadProgress.finish();</script>'  # put some kind of error message on this one?
      render :text => '<script type="text/javascript">window.parent.showImage(\'' + @image.id.to_s + '\', ' + rollover.to_s + ');</script>'
    else
      render :text => ".jpg only"
    end
  end
  
  def add_image2
    if params['image']['tmp_file'].original_filename[-4..-1].downcase == ".jpg"
      Delayed::Job.enqueue(UploadJob.new(params))
      render :text => "<script>window.parent.Uploader.begin(5, 1);</script>"
    else
      render :text => "<script>window.parent.Uploader.begin(5, 0);</script>"
    end
  end
  
  def edit_image
    @image = Image.find(params['image_id'])
  end
  
  def d_image #delete image.  can this be changed back to delete_image?
    @image = Image.find(params['image_id'])
    @image.delete_s3
    Image.destroy(params['image_id'])
    Portfolio.update_counters @image.portfolio_id, :images_count => -1 # kj: decrement portfolio image_count
    update_stat('aCQyu7taGOKOgZ7JulJlaq0djvz', 'count')
    render :nothing => true
  end
  
  def update_biography
    current_user.info.biography = params['biography'].gsub(/&/, 'and')
    current_user.info.biodisplay = params['biodisplay']
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def update_biopic
    if params['tmp_file'].original_filename =~ /\.jpg$/i
      pic = Magick::Image.from_blob(params['tmp_file'].read).first
      pic.resize_to_fit!(300, 460) if pic.columns > 300 or pic.rows > 460
      s3_updatefile "biopic" + current_user.id.to_s + ".jpg", pic.to_blob {self.quality = 90}
      current_user.info.add_biopic
      biopicmessage = '<span style="font-style: italic; color: #00BB00;"><b>Uploaded</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      biopicmessage = '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Image must be a .JPG</span>'
    end
    redirect_to :action => "personal", :page => "bio_picture", :message => biopicmessage
  end
  
  def delete_biopic
    if s3_deletefile "biopic" + current_user.id.to_s + ".jpg"
      current_user.info.remove_biopic
      biopicmessage = '<span style="font-style: italic; color: #00BB00;"><b>Deleted</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      biopicmessage = '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not be deleted</span>'
    end
    redirect_to :action => "personal", :page => "bio_picture", :message => biopicmessage
  end
  
  def biopic_display
    current_user.info.biopicdisplay = params['biopicdisplay'] == "true" ? true : false
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def update_resume
    if params['tmp_file'].original_filename =~ /\.pdf$/
      s3_updatefile "resume" + current_user.id.to_s + ".pdf", params['tmp_file'].read
      current_user.info.add_resume
      resmessage = '<span style="font-style: italic; color: #00BB00;"><b>Uploaded</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      resmessage = '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Incorrect file format</span>'
    end
    redirect_to :action => "personal", :page => "resume", :message => resmessage
  end
  
  def delete_resume
    if s3_deletefile "resume" + current_user.id.to_s + ".pdf"
      current_user.info.delete_resume
      resmessage = '<span style="font-style: italic; color: #00BB00;"><b>Deleted</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      resmessage = '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not be deleted</span>'
    end
    redirect_to :action => "personal", :page => "resume", :message => resmessage
  end
  
  def resume_display
    current_user.info.resumedisplay = params['resumedisplay'] == "true" ? true : false
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def update_info
    current_user.info.name          = params['name'].gsub(/&/, 'and')
    current_user.info.email         = params['email'].gsub(/&/, 'and')
    current_user.info.title         = params['title'].gsub(/&/, 'and')
    current_user.info.toptext       = params['toptext'].gsub(/&/, 'and')
    current_user.info.description   = params['description'].gsub(/&/, 'and')
    current_user.info.keywords      = params['keywords'].gsub(/&/, 'and')
    current_user.info.verifyv1      = params['verifyv1']
    current_user.info.contact_info  = params['contact_info'].gsub(/&/, 'and')
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def update_links
    # to_s helps take care of the nil cases by turning nil into ''
    current_user.info.link_portfolios     = params['link_portfolios'].to_s.gsub(/&/, 'and')
    current_user.info.link_multimedia     = params['link_multimedia'].to_s.gsub(/&/, 'and')
    current_user.info.link_biography      = params['link_biography'].to_s.gsub(/&/, 'and')
    current_user.info.link_contact        = params['link_contact'].to_s.gsub(/&/, 'and')
    current_user.info.link_resume         = params['link_resume'].to_s.gsub(/&/, 'and')
    current_user.info.link_clientaccess   = params['link_clientaccess'].to_s.gsub(/&/, 'and')
    current_user.info.link1               = params['link1'].to_s.gsub(/&/, 'and')
    current_user.info.link2               = params['link2'].to_s.gsub(/&/, 'and')
    current_user.info.link3               = params['link3'].to_s.gsub(/&/, 'and')
    current_user.info.link1_address       = params['link1_address'].to_s
    current_user.info.link2_address       = params['link2_address'].to_s
    current_user.info.link3_address       = params['link3_address'].to_s
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def update_favicon
    if params['tmp_file'].original_filename =~ /\.ico$/
      s3_updatefile "favicon" + current_user.id.to_s + ".ico", params['tmp_file'].read
      current_user.info.add_favicon
      favmessage = '<span style="font-style: italic; color: #00BB00;"><b>Uploaded</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      favmessage = '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Incorrect file format</span>'
    end
    redirect_to :action => "layout", :page => "favicon", :message => favmessage
  end
  
  def delete_favicon
    if s3_deletefile "favicon" + current_user.id.to_s + ".ico"
      current_user.info.remove_favicon
      favmessage = '<span style="font-style: italic; color: #00BB00;"><b>Deleted</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      favmessage = '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not be deleted</span>'
    end
    redirect_to :action => "layout", :page => "favicon", :message => favmessage
  end
  
  def psslink_display
    current_user.info.psslinkdisplay = params['psslinkdisplay'] == "true" ? true : false
    if current_user.info.save
      render :text => '<span style="font-style: italic; color: #00BB00;"><b>Saved</b> @ ' + Time.now.strftime("%I:%M:%S %p").downcase + '</span>'
    else
      render :text => '<span style="font-weight: bold; font-style: italic; color: #EE0000;">Could not save</span>'
    end
  end
  
  def fullscreen
    if logged_in?
      current_user.wide = true
      current_user.save
    end
    render :nothing => true
  end
  
  def unfullscreen
    if logged_in?
      current_user.wide = false
      current_user.save
    end
    render :nothing => true
  end
  
  def process_password
    if params['password1'].to_s == current_user.pass && params['password2'].to_s == params['password3'].to_s
      current_user.pass = params['password2'].to_s
      current_user.save
      render :text => "Password update successful."
    else
      render :text => "There was an error.  You may have entered your current password incorrectly, or did not type the same new password twice.  Please refresh and try again."
    end
  end
  
  def test
    @section = "Test"
  end

  def news
    @section = "News"
    @announcements = Announcement.find(:all, :order => "posted DESC")
  end
  
  def show_partial
    render :partial => params['name']
  end
  
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
  
# protected
#   def check_login
#     if session[:user].nil?
#       redirect_to :action => "index"
#     end
#   end

  protected
  
  def authorized
    logged_in? and current_user.status != "Suspended"
  end

  def update_stat(key, type)
    return;
    args = {:key => key, :ukey => STATHAT_UKEY}
    args[type] = 1
    res = Net::HTTP.post_form(URI.parse('http://stathat.com/api/c'), args)
  end
  
end
