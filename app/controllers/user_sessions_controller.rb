class UserSessionsController < ApplicationController
  require_dependency 'vendor/plugins/blacklight/app/controllers/user_sessions_controller'

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
       redirect_to root_path
    else
      flash.now[:error] =  "Couldn't locate a user with those credentials"
      render :action => :new
    end
  end
end
