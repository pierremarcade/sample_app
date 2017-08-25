class MicropostsController < ApplicationController
  before_action :authenticate, :only => [:create, :destroy]
  before_action :authorized_user, :only => :destroy

  def create
    @micropost  = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = t(:microposts_created)
      redirect_to root_path(params_link)
    else
      @feed_items = []
      render 'pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_back_or root_path(params_link)
  end
  
  def micropost_params
      params.require(:micropost).permit(:content, :user_id)
  end
  
  private
    def authorized_user
      @micropost = Micropost.find(params[:id])
      redirect_to root_path(params_link) unless current_user?(@micropost.user)
    end
end
