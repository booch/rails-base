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
    #TODO: Add suspend column to user and implement this
  end

  def unsuspend
    #TODO: Should this and suspend be dry'd up?
  end

  def roles
    #TODO: Clean up view with helper
    @user  = User.find params[:id]
    @roles = Role.find :all
  end

  def change_roles
    @user = User.find params[:id]
    @user.roles = Role.find params[:user][:roles]
    @user.save

    redirect_to :action => :index
  end

  def remove_roles
    @user = User.find params[:id]
    role = Role.find params[:roles][:id]
    @user.roles.delete role
  end

end
