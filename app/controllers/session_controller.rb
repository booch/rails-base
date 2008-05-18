class SessionController < ApplicationController

  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      current_user.update_attribute(:last_login_at, Time.now)

      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      invalid_user = User.find(:first, :conditions => {:login => params[:login]})
      if invalid_user && !invalid_user.activated?
        flash[:error] = "Account has not been activated"
      else
        flash[:error] = "Incorrect username or password"
      end
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to login_url
  end

  def logout
    destroy
  end
end
