class DisplaySweeper < ActionController::Caching::Sweeper
  
  observe Portfolio, Image, Info
  
  def before_save(record)
    case record
      when Info
        sweep_index(record.user)
        sweep_phone(record.user)
        sweep_tablet(record.user)
        sweep_splash(record.user)
        sweep_flash_info(record.user)
      when Portfolio
        sweep_index(record.user)
        sweep_phone(record.user)
        sweep_tablet(record.user)
        sweep_splash(record.user)
        sweep_flash_info(record.user)
      when Image
        sweep_index(record.portfolio.user) if record.portfolio
        sweep_phone(record.portfolio.user) if record.portfolio
        sweep_tablet(record.portfolio.user) if record.portfolio
        sweep_splash(record.portfolio.user) if record.portfolio
        sweep_flash_info(record.portfolio.user) if record.portfolio
    end
  end
  
  def before_destroy(record)
    case record
      when Info
        sweep_index(record.user)
        sweep_phone(record.user)
        sweep_tablet(record.user)
        sweep_splash(record.user)
        sweep_flash_info(record.user)
      when Portfolio
        sweep_index(record.user)
        sweep_phone(record.user)
        sweep_tablet(record.user)
        sweep_splash(record.user)
        sweep_flash_info(record.user)
      when Image
        sweep_index(record.portfolio.user) if record.portfolio
        sweep_phone(record.portfolio.user) if record.portfolio
        sweep_tablet(record.portfolio.user) if record.portfolio
        sweep_splash(record.portfolio.user) if record.portfolio
        sweep_flash_info(record.portfolio.user) if record.portfolio
    end
  end
  
  private

  %w{index phone tablet splash flash_info}.each do |page|
    define_method("sweep_#{page}") do |user|
      cache_dir = RAILS_ROOT + "/tmp/cache/"
      FileUtils.rm_r(cache_dir + "display/#{page}.#{user.id}.cache") if FileTest.exist?(cache_dir + "display/#{page}.#{user.id}.cache")
    end
  end

end