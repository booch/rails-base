class UsersController < ApplicationController
  before_filter :login_required
  require_role "admin"


  def index
    @users = User.find :all
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

end
