module StanfordWebauthIntegration::ControllerMethods
  
  def set_current_user
    unless Rails.env =~ /production/ 
      if params[:wau]
        logger.warn("Setting WEBAUTH_USER in dev mode!")
        request.env['WEBAUTH_USER']=params[:wau]
      end
    end
    session[:user]=request.env['WEBAUTH_USER'] unless request.env['WEBAUTH_USER'].blank?
  end
  
end