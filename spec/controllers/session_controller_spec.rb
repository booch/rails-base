require File.dirname(__FILE__) + '/../spec_helper'

describe SessionController do
  fixtures :users

  before(:each) do
    users(:quentin).activate!
  end

  it 'logins and redirects' do
    post :create, :login => 'quentin', :password => 'test'
    session[:user_id].should_not be_nil
    response.should be_redirect
  end
  
  it 'fails login and does not redirect' do
    post :create, :login => 'quentin', :password => 'bad password'
    session[:user_id].should be_nil
    response.should be_success
  end

  it 'should fail login and not redirect if user account is suspended' do
    post :create, :login => 'suspended', :password => 'test'
    session[:user_id].should be_nil
    response.should be_success
  end

  it 'should fail login and not redirect if user account has not been activated' do
    post :create, :login => 'unactivated', :password => 'test'
    session[:user_id].should be_nil
    response.should be_success
  end


  it 'logs out' do
    post :create, :login => 'quentin', :password => 'test'
    get :destroy
    session[:user_id].should be_nil
    response.should be_redirect
  end

  it 'remembers me' do
    post :create, :login => 'quentin', :password => 'test', :remember_me => "1"
    response.cookies["auth_token"].should_not be_nil
  end
  
  it 'does not remember me' do
    post :create, :login => 'quentin', :password => 'test', :remember_me => "0"
    response.cookies["auth_token"].should be_nil
  end

  it 'deletes token on logout' do
    post :create, :login => 'quentin', :password => 'test'
    get :destroy
    response.cookies["auth_token"].should == []
  end

  it 'logs in with cookie' do
    users(:quentin).remember_me
    request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    controller.send(:logged_in?).should be_true
  end
  
  it 'fails expired cookie login' do
    users(:quentin).remember_me
    users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    controller.send(:logged_in?).should_not be_true
  end
  
  it 'fails cookie login' do
    users(:quentin).remember_me
    request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    controller.send(:logged_in?).should_not be_true
  end

  it 'should fail login until account is activated' do
    post :create, :login => 'aaron', :password => 'test', :remember_me => "0"
    session[:user_id].should be_nil
    response.should_not be_redirect

    users(:aaron).activate!

    post :create, :login => 'aaron', :password => 'test', :remember_me => "0"
    session[:user_id].should_not be_nil
    response.should be_redirect
  end

  it 'should redirect activated users to homepage when they log in' do
    post :create, :login => 'activated', :password => 'test'
    session[:user_id].should_not be_nil
    response.should be_redirect
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
    
  def cookie_for(user)
    auth_token users(user).remember_token
  end
end
