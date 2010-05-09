#
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#
class ApplicationController < ActionController::Base
  
  include HydraAccessControlsHelper
  include StanfordWebauthIntegration::ControllerMethods
  
  filter_parameter_logging :password, :password_confirmation  
  helper_method :current_user_session, :current_user
  
  helper :all
  helper :hydra_access_controls, :hydra_djatoka, :downloads, :metadata, :hydra
  
  helper_method [:request_is_for_user_resource?]#, :user_logged_in?]
  before_filter [:set_current_user, :store_bounce]
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '200c1e5f25e610288439b479ef176bbd'
  
  protected
  def store_bounce 
    session[:bounce]=params[:bounce]
  end

end
