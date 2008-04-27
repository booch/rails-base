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

  def destroy
  end

  def suspend
  end

  def roles
  end

  def add_roles
    @user = User.find params[:id]
    role = Role.find params[:roles][:id]
    @user.roles << role
  end

  def remove_roles
    @user = User.find params[:id]
    role = Role.find params[:roles][:id]
    @user.roles.delete role
  end

end
