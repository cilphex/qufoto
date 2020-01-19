# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  
  include AuthenticatedSystem
  
  filter_parameter_logging :pass
  
  def method_missing(methodname, *args)
    @help = true
    render :action => 'error_404', :status => 404
  end
  
  # Other controllers call this method when ActiveRecord call RecordNotFound
  def record_not_found
    render :text => "Website not found"
  end
  
end