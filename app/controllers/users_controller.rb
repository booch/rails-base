class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  def show
    @user = User.find(params[:id])
  end

  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    user = User.find(params[:id])

    user.email = params[:user][:email] unless params[:user][:email].blank?

    unless params[:user][:password].blank?
      user.password_confirmation = params[:user][:password_confirmation]
      user.password = params[:user][:password]
    end

    user.save

    redirect_to :action => :edit
  end

  def activate
    @user = User.find_by_activation_code(params[:id])
    if @user and @user.activate!
      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Your account has been activated." 
    end
  end

  def forgot_password; end

  def create_password_reset_code
    if @user = User.find_by_email(params[:email])
      @user.forgot_password
      @user.save
      redirect_back_or_default('/')
      flash[:notice] = "A password reset link has been sent to your email address" 
    else
      flash[:notice] = "Could not find a user with that email address" 
    end
  end


  def reset_password
    @password_reset_code = params[:id]
  end

  def change_forgotten_password
    user = User.find_by_password_reset_code(params[:password_reset_code])
    if params[:password] == params[:password_confirmation]

      user.password_confirmation = params[:password_confirmation]
      user.password = params[:password]
      user.reset_password

      flash[:notice] = user.save ? "Password reset" : "Password not reset" 
      redirect_back_or_default(:action => "reset_password")
    else
      flash[:notice] = "Password mismatch" 
    end  
  end

end
