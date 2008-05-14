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

    if @user.save
      flash[:notice] = "User '#{@user.login}' created."
    else
      flash[:error] = "User '#{@user.login}' could not be created."
    end

    redirect_to :action => :index
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]

    if @user.update_attributes(params[:user])
      flash[:notice] = "User '#{@user.login}' updated."
    else
      flash[:error] = "User '#{@user.login}' could not be updated."
    end

    redirect_to :action => :index
  end

  def suspend
    @user = User.find params[:id]
    
    if @user.suspend!
      flash[:notice] = "User '#{@user.login}' suspended."
    else
      flash[:error] = "User '#{@user.login}' could not be suspended."
    end

    redirect_to :action => :index
  end

  def unsuspend
    @user = User.find params[:id]

    if @user.unsuspend!
      flash[:notice] = "User '#{@user.login}' unsuspended."
    else
      flash[:error] = "User '#{@user.login}' could not be unsuspended."
    end

    redirect_to :action => :index
  end

  def reset_password
    @user = User.find params[:id]

    if @user.forgot_password
      flash[:notice] = "User '#{@user.login}' password has been reset."
    else
      flash[:error] = "User '#{@user.login}' password could not be reset."
    end


    redirect_to :action => :index
  end

  def roles
    @user  = User.find params[:id]
    @roles = Role.find :all
  end

  def change_roles
    @user = User.find params[:id]
    @user.roles = Role.find params[:user][:roles]

    if @user.save
      flash[:notice] = "Roles of user '#{@user.login}' are now '#{@user.roles.map(&:name).join(', ')}'."
    else
      flash[:error] = "Roles of user '#{@user.login}' could not be updated."
    end

    redirect_to :action => :index
  end
end
