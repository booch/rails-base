class UsersController < ApplicationController
  before_filter :login_required
  require_role "admin"

  def index
    @users = User.find :all
  end

  def show
    @user = User.find params[:id]
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.save

    redirect_to :action => :index
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]
    @user.update_attributes(params[:user])

    redirect_to :action => :edit
  end

  def suspend
    @user = User.find params[:id]
    @user.suspend!

    redirect_to :action => :index
  end

  def unsuspend
    @user = User.find params[:id]
    @user.unsuspend!

    redirect_to :action => :index
  end

  def reset_password
    @user = User.find params[:id]
    @user.forgot_password

    redirect_to :action => :index
  end

  def roles
    @user  = User.find params[:id]
    @roles = Role.find :all
  end

  def change_roles
    @user = User.find params[:id]
    @user.roles = Role.find params[:user][:roles]
    @user.save

    redirect_to :action => :index
  end
end
