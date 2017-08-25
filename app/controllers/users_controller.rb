class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate, :only => [:show, :index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user, :only => [:edit, :update]
  before_action :admin_user,   :only => :destroy
  
  def index
    @title = t(:all_users)
    @users = User.paginate(page: params[:page], :per_page => 5)
  end
  
  def show
    @title = @user.name
    @microposts = @user.microposts.paginate(:page => params[:page])
  end
  
  def new
    @user = User.new
    @title = t(:registration)
  end
  
  def edit
    @title = t(:edit_profile)
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = t('controllers.users.create.welcome_on_app')
      redirect_to user_path(@user, params_link)
    else
      @title = t(:registration)
      render 'new'
    end
  end
  
  def update
    if @user.update(user_params)
      flash[:success] = t(:profil_updated)
      redirect_to user_path(@user, params_link)
    else
      @title = t(:edit_profile)
      render 'edit'
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "Utilisateur supprimé."
    redirect_to users_path(params_link)
  end
  
  def following
    @titre = t(:following_title)
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end

  def followers
    @titre = t(:follower_title)
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
  end
  
  private
   # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path(params_link)) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_path(params_link)) unless current_user.admin?
    end

end
