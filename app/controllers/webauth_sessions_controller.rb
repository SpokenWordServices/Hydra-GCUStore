class WebauthSessionsController < ApplicationController
  skip_before_filter :store_bounce
  def new
    redirect_to session[:bounce]
  end
  def destroy
    redirect_to 'https://weblogin.stanford.edu/logout'
  end
end
