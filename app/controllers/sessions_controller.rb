class SessionsController < ApplicationController
  def new
    @title = t(:sign_in)
  end
  
  def create
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])
    if user.nil?
      flash.now[:error] = t('controllers.sessions.create.connection_error')
      @title = t(:sign_in)
      render 'new'
    else
      sign_in user
      redirect_back_or user_path(user, params_link)
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path(params_link)
  end
end
