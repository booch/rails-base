require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe UsersController do
  fixtures :users

  it 'allows signup' do
    lambda do
      create_user
      response.should be_redirect
    end.should change(User, :count).by(1)
  end

  it 'requires login on signup' do
    lambda do
      create_user(:login => nil)
      assigns[:user].errors.on(:login).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      assigns[:user].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_user(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'should allow a user that forgot their password to create a password_reset_code' do
    users(:aaron).password_reset_code.should be_nil

    post :create_password_reset_code, :email => users(:aaron).email

    users(:aaron).reload
    users(:aaron).password_reset_code.should_not be_nil
  end

  it 'should allow a user with a recent password_reset_code to change their password' do
    old_password = users(:aaron).crypted_password

    post :create_password_reset_code, :email => users(:aaron).email

    users(:aaron).reload
    post :change_forgotten_password,
      :password_reset_code => users(:aaron).password_reset_code,
      :password => "newpassword",
      :password_confirmation => "newpassword"

    users(:aaron).reload
    new_password = users(:aaron).crypted_password

    old_password.should_not == new_password
  end

  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire', :password_confirmation => 'quire' }.merge(options)
  end
end