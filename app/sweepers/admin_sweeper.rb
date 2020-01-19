class AdminSweeper < ActionController::Caching::Sweeper
  
  observe User, Info, Interview, Announcement, Example
  
  def before_save(record)
    case record
      when User
        sweep_browse_and_profit
        sweep_user(record)
      when Info
        sweep_user(record.user)
      when Interview
        sweep_index
        sweep_interviews(record)
      when Announcement
        sweep_index
      when Example
        sweep_examples(record)
    end
  end
  
  def before_destroy(record)
    case record
      when User
        sweep_browse_and_profit
        sweep_user(record)
      when Info
        sweep_user(record.user)
      when Interview
        sweep_index
        sweep_interviews(record)
      when Announcement
        sweep_index
      when Example
        sweep_examples(record)
    end
  end
  
  private
  
  def sweep_browse_and_profit
    cache_dir = RAILS_ROOT + "/tmp/cache/"
    FileUtils.rm_r(cache_dir + "admin/browse.cache") if FileTest.exist?(cache_dir + "admin/browse.cache")
    FileUtils.rm_r(cache_dir + "admin/profit_report.cache") if FileTest.exist?(cache_dir + "admin/profit_report.cache")
  end
  
  def sweep_user(user)
    cache_dir = RAILS_ROOT + "/tmp/cache/"
    FileUtils.rm_r(cache_dir + "admin/user.#{user.id}.cache") if FileTest.exist?(cache_dir + "admin/user.#{user.id}.cache")
  end
  
  def sweep_index
    cache_dir = RAILS_ROOT + "/tmp/cache/"
    FileUtils.rm_r(cache_dir + "qufoto/index.cache") if FileTest.exist?(cache_dir + "qufoto/index.cache")
    #expire_action :controller => "qufoto2", :action => "index"
  end
  
  def sweep_interviews(interview)
    cache_dir = RAILS_ROOT + "/tmp/cache/"
    FileUtils.rm_r(cache_dir + "qufoto/interviews.cache") if FileTest.exist?(cache_dir + "qufoto/interviews.cache")
    FileUtils.rm_r(cache_dir + "qufoto/interviews.rss.cache") if FileTest.exist?(cache_dir + "qufoto/interviews.rss.cache")
    FileUtils.rm_r(cache_dir + "qufoto/interviews.#{interview.url}.cache") if FileTest.exist?(cache_dir + "qufoto/interviews.#{interview.url}.cache")
    #expire_action :controller => "qufoto2", :action => "interviews"
    #expire_action :controller => "qufoto2", :action => "interviews", :id => "rss"
    #expire_action :controller => "qufoto2", :action => "interviews", :id => interview.id
  end
  
  def sweep_examples(example)
    cache_dir = RAILS_ROOT + "/tmp/cache/"
    FileUtils.rm_r(cache_dir + "qufoto/examples.cache") if FileTest.exist?(cache_dir + "qufoto/examples.cache")
    FileUtils.rm_r(cache_dir + "qufoto/examples.#{example.id}.cache") if FileTest.exist?(cache_dir + "qufoto/examples.#{example.id}.cache")
    #expire_action :controller => "qufoto2", :action => "examples"
    #expire_action :controller => "qufoto2", :action => "examples", :id => example.id
  end
  
end