class QufotoController < ApplicationController
  
  layout "qufoto"
  
  # You can't get caches_page to work without fucking up non-qufoto.com domains yet.  Come back to it later.
  # caches_page :index, :examples, :prices, :featured, :signup, :faq, :contact, :news, :sites, :help
  
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  # Do NOT make an index method.  When it creates the index.html in the public dir,
  # that page gets rendered instead of user sites, fucking things up. Or... make
  # one and find a way to not have it set at index.html.

  def index
    @announcements = Announcement.find(:all, :order => "posted DESC", :limit => 4)
  end

  def examples
    @title = "Qufoto.com - Examples"
  end
  
  def features
    @title = "Qufoto.com - Features"
  end
  
  def prices
    @title = "Qufoto.com - Prices"
  end
  
  def featured
    @title = "Qufoto.com - Featured Photographer Interviews"
  end
  
  def signup
    @title = "Qufoto.com - Signup"
  end
  
  def faq
    @title = "Qufoto.com - FAQ"
  end
  
  def contact
    @title = "Qufoto.com - Contact Us"
  end
  
  def news
    if params['id'].nil?
      @announcements = Announcement.find(:all, :order => "posted DESC")
      @title = "Qufoto.com - News"
    else
      @announcement = Announcement.find(params['id'], :order => "posted DESC")
      @title = "Qufoto.com - News - #{@announcement.title}"
      render :action => "news_item"
    end
  end
  
  def about
  end
  
  def terms
  end
  
  def privacy
  end
  
  def subscriptions
  end
  
  def sites
    @users = User.find(:all, :order => "id DESC", :conditions => "subscription != 0 AND status != 'Suspended'")
  end
  
  def help
    @title = "Qufoto.com - Help"
    render :action => "getting_started"
  end
  
  def thankyou
    @tx = false
    if !params[:tx].nil?
      tx_token = params[:tx]
      auth_token = 'T2OW7eLv4RGD1NzS9ojLoL38PkrcWxUUCFPDOIek-s9gBz54ItWca9w8iV4'
      res = Net::HTTP.post_form(URI.parse('http://www.paypal.com/cgi-bin/webscr'), {'cmd' => '_notify-synch', 'tx' => params['tx'], 'at' => 'T2OW7eLv4RGD1NzS9ojLoL38PkrcWxUUCFPDOIek-s9gBz54ItWca9w8iV4'})
      @vals = Hash.new
      res.body.each_line do |line|
        @vals[line.split('=')[0]] = line.split('=')[1]
      end
      @tx = true if @vals.has_key?('payer_email')
    end
    @name = @tx ? CGI::unescape(@vals['first_name']).strip : "TestUser"
    @email = @tx ? CGI::unescape(@vals['payer_email']).strip : "TestEmail"
    if !params[:tx].nil?
      Mailer.deliver_signup_email(@name, @email)
    end
  end
  
  def paypal_ipn
    referral_code = params['custom'].split('|')[1]
    if referral_code == "56F980"
      Mailer.deliver_yay_referral(params[:first_name], params[:payer_email], params[:item_name])
    end
    render :text => ''
  end
  
  def cancel
  end
  
  # should the following methods be protected, too?
  
  def send_comment
    comment = Comment.new do |c|
      c.sender = params['name']
      c.replyTo = params['email']
      c.body = params['body']
    end
    comment.save
    Mailer.deliver_comment(comment)
    render :text => "Your comment has been sent"
  end
    
  def send_referrer
    body = "#{params['refer_user']} was referred by #{params['refer_type']}."
    body += " Specifically: #{params['refer_detail']}." if params['refer_detail'] != 'none'
    c = Comment.create(
      :sender => params['refer_user'],
      :replyTo => params['refer_email'],
      :body => body
    )
    Mailer::deliver_comment(c) if c
    render :text => "1"
  end
  
  def check_domain
    if (params['domain'] =~ /[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]\.(com|net|org|us|biz|info)/) != 0
      render :text => "Invalid domain.  Please do not use 'http://', 'www', spaces, or sub-domains."
    else
      whois = `whois #{params['domain']}`
      if whois.include?("No match")
        render :text => "#{params['domain']} is <b class='green'>available</span>."
      else
        render :text => "#{params['domain']} is <b class='red'>taken</span>."
      end
    end
  end
  
  protected
  
  def find_server
    if params["user"]
      @user = User.find_by_user(params["user"])
    else
      server = request.env['HTTP_X_FORWARDED_HOST'].gsub(/^www\./, '')
      @user = User.find_active_website(server)
    end
    @user
  end
  
end
