class Qufoto2Controller < ApplicationController
  
  layout "qufoto2"
  
  before_filter :setup_pages
  
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  
  # These pages seemed to take the longest to render, I guess because there are some queries
  caches_action :index,      :cache_path => "qufoto/index"
  caches_action :examples,   :cache_path => :examples_cache_path.to_proc
  caches_action :interviews, :cache_path => :interviews_cache_path.to_proc
  
  def setup_pages
    @pages = [
      {:path => 'sitemap',    :title => 'Sitemap',    :bottom => true},
      {:path => 'features',   :title => 'Features',   :top => true},
      {:path => 'examples',   :title => 'Examples',   :top => true},
      {:path => 'prices',     :title => 'Prices',     :top => true},
      {:path => 'faq',        :title => 'FAQ',        :top => true, :bottom => true},
      {:path => 'contact',    :title => 'Contact Us', :top => true, :bottom => true},
      {:path => 'signup',     :title => 'Sign Up',    :top => true, :bottom => true}
    ]
  end
  
  def routing_error
    render :text => 'Fucked'
  end
  
  def index
    @body_class = "landing"
    @interview = Interview.find(:first, :order => 'position ASC, id DESC', :conditions => 'enabled = true')
    @news = Announcement.find(:first, :order => 'posted DESC')
  end
  
  def error_404
    @help = true
  end
  
  def features
    @page = "features"
    @title = "Photography Websites - Features"
    @body_class = "features"
  end
  
  def prices
    @page = "prices"
    @title = "Online Portfolios - Prices"
    @body_class = "prices"
  end
  
  def examples
    @page = "examples"
    @title = "Photography Website Templates - Examples"
    @body_class = "examples"
    @examples = Example.find(:all, :order => 'position ASC', :conditions => ['enabled = ?', true])
    if params[:id] && Example.exists?(params[:id])
      @featured = Example.find(params[:id])
    end
  end
  
  def faq
    @page = "faq"
    @title = "Frequently Asked Questions"
    @body_class = "faq"
  end
  
  def news
    if params['id'].nil?
      @announcements = Announcement.find(:all, :order => "posted DESC")
      @title = "News"
      @body_class = "news"
    else
      @announcement = Announcement.find(params['id'], :order => "posted DESC")
      @title = "News - #{@announcement.title}"
      @body_class = "news_item"
      render :action => :news_item
    end
  end
  
  def interviews
    if params[:id]
      if params[:id] == 'rss'
        @interviews = Interview.find(:all, :order => 'position ASC, id DESC', :limit => 10, :conditions => ['enabled = ?', true])
        response.headers['Content-Type'] = 'application/xml; charset=utf-8'
        render :action => :interviews_rss, :layout => false
      else
        if params[:id] =~ /\d+/
          @interview = Interview.find(:first, :conditions => ['id = ?', params[:id]])
        else
          @interview = Interview.find(:first, :conditions => ['url = ?', params[:id]])
        end
        @title = @interview ? "Interview with #{@interview.interviewee}" : "Interview not found"
        @body_class = "interview"
        render :action => 'interview'
      end
    else
      @title = "Interviews with Featured Photographers"
      @body_class = "interviews"
      @interviews = Interview.find(:all, :order => 'position ASC, id DESC', :conditions => ['enabled = ?', true])
    end
  end
  
  def about
    @page = "faq"
    @title = "About Us"
    @body_class = "about"
  end
  
  def help
    redirect_to :action => :contact
  end
  
  def contact
    @page = "contact"
    @help = true
    @title = "Contact Us"
    @body_class = "contact"
  end
  
  def press
    @page = "press"
    @title = "Press"
    @body_class = "press"
  end
  
  def signup
    @page = "signup"
    @title = "Signup"
    @body_class = "signup"
  end
  
  def getting_started
    @page = "faq"
    @title = "Getting Started"
    @body_class = "getting_started"
  end
  
  def customize
    @page = "faq"
    @title = "Customizing Your Site"
    @body_class = "customize"
  end
  
  def domains
    @page = "faq"
    @title = "Domains"
    @body_class = "domains"
  end
  
  def email
    @page = "faq"
    @title = "Email Addresses"
    @body_class = "email"
  end
  
  def analytics
    @page = "faq"
    @title = "Analytics"
    @body_class = "analytics"
  end
  
  def seo
    @page = "faq"
    @title = "Analytics"
    @body_class = "seo"
  end
  
  def referrals
    @page = "faq"
    @title = "Referral Program"
    @body_class = "referrals"
  end
  
  def user_guide
    @page = "faq"
    @title = "User guide"
    @body_class = "user_guide"
  end
  
  def sitemap
    @title = "Photo Websites for Photographers - Sitemap"
    @body_class = "sitemap"
  end

  def testimonials
    @title = "Testimonials"
    @body_class = "testimonials"
  end
  
  def sites
    @body_class = "sites"
    @users = User.find(:all, :order => "id DESC", :conditions => "subscription != 0 AND status != 'Suspended'")
  end
  
  # Used on the contact page
  def send_comment
    comment = Comment.new do |c|
      c.sender = params[:name]
      c.replyTo = params[:email]
      c.body = params[:body]
    end
    comment.save
    Mailer.deliver_comment(comment)
    render :json => {:success => 1}
  end
  
  def check_domain
    if (params['domain'] =~ /[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]\.(com|net|org|us|biz|info)/) != 0
      render :json => {:invalid => 1, :domain => params[:domain]}
    else
      whois = `whois #{params['domain']}`
      if whois.include?("No match")
        render :json => {:available => 1, :domain => params[:domain]}
      else
        render :json => {:available => 0, :domain => params[:domain]}
      end
    end
  end

  # The url to which PayPal posts information about the transaction, in the form of
  # an Instant Payment Notification message
  def paypal_ipn
    # Currently nothing happens here.
    render :text => ''
  end

  def thankyou
    @page = "faq"
    @title = "Thanks!"
    @body_class = "thankyou"
    @tx = false
    if !params[:tx].nil?
      tx_token = params[:tx]
      auth_token = 'T2OW7eLv4RGD1NzS9ojLoL38PkrcWxUUCFPDOIek-s9gBz54ItWca9w8iV4'
      res = Net::HTTP.post_form(URI.parse('http://www.paypal.com/cgi-bin/webscr'), {:cmd => '_notify-synch', :tx => params[:tx], :at => 'T2OW7eLv4RGD1NzS9ojLoL38PkrcWxUUCFPDOIek-s9gBz54ItWca9w8iV4'})
      @vals = Hash.new
      res.body.each_line do |line|
        @vals[line.split('=')[0]] = line.split('=')[1]
      end
      @tx = true if @vals.has_key?('payer_email')
    end
    @name = @tx ? CGI::unescape(@vals['first_name']).strip : "TestUser"
    @email = @tx ? CGI::unescape(@vals['payer_email']).strip : "TestEmail"
  end
  
  def send_referrer
    body = "#{params[:refer_user]} was referred by #{params[:refer_type]}."
    body += " Specifically: #{params[:refer_detail]}." if params[:refer_detail] != 'none'
    c = Comment.create(
      :sender => params[:refer_user],
      :replyTo => params[:refer_email],
      :body => body
    )
    Mailer::deliver_comment(c) if c
    render :json => {:success => 1}
  end
  
  protected
  
  def find_server
    if params[:user]
      @user = User.find_by_user(params[:user])
    else
      server = request.env['HTTP_X_FORWARDED_HOST'].gsub(/^www\./, '')
      @user = User.find_active_website(server)
    end
    @user
  end
  
  def examples_cache_path
    "qufoto/examples" + (params[:id] ? ".#{params[:id]}" : "")
  end
  
  def interviews_cache_path
    "qufoto/interviews" + (params[:id] ? ".#{params[:id]}" : "")
  end

end