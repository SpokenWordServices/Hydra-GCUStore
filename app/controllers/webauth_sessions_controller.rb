class WebauthSessionsController < ApplicationController
  skip_before_filter :store_bounce
  def new
    redirect_to session[:bounce] if session[:bounce]
  end
  def destroy
    session[:bounce]=nil
    session[:user]=nil
    redirect_to 'https://weblogin.stanford.edu/logout'
  end
end
