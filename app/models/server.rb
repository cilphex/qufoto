class Server < ActiveRecord::Base

  # Class methods
  class << self
    def updating
      find(0).updating
    end
    
    def go_down
      find(0).update_attribute(:updating, true)
    end
    
    def bring_up
      find(0).update_attribute(:updating, false)
    end
    
    def toggle_status
      updating ? bring_up : go_down
    end
  end

end