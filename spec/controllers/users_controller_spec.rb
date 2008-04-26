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

  describe 'without logging in' do
    it 'should not allow access to pages that need authentication' do
      response = get(:show)
      response.should be_redirect

      response = get(:edit)
      response.should be_redirect

      response = put(:update)
      response.should be_redirect
    end

    it 'should allow access to public pages' do
      response = get(:activate, :id => "fake")
      response.should_not be_redirect

      response = get(:reset_password)
      response.should_not be_redirect

      response = get(:forgot_password)
      response.should_not be_redirect
    end
  end

  describe 'after logging in' do
    before(:each) do
      login_as(:aaron)
    end

    it 'should allow a user with a recent password_reset_code to change their password if two matching passwords are supplied' do
      old_password = users(:aaron).crypted_password

      post :create_password_reset_code, :email => users(:aaron).email

      users(:aaron).reload
      post :change_forgotten_password,
        :password_reset_code => users(:aaron).password_reset_code,
        :password => "newpassword",
        :password_confirmation => "newpassword"

      users(:aaron).reload
      new_password = users(:aaron).crypted_password

      new_password.should_not == be_nil
      new_password.should_not == old_password
    end

    it 'should not allow a user with a recent password_reset_code to change their password if two different passwords are supplied' do
      old_password = users(:aaron).crypted_password

      post :create_password_reset_code, :email => users(:aaron).email

      users(:aaron).reload
      post :change_forgotten_password,
        :password_reset_code => users(:aaron).password_reset_code,
        :password => "onepassword",
        :password_confirmation => "twopassword"

      users(:aaron).reload
      new_password = users(:aaron).crypted_password

      new_password.should == old_password
    end

    it 'should allow a user to change their email address' do
      old_email = users(:aaron).email

      put :update,
        :id => users(:aaron).id,
        :user => { :email => "new@new.new" }

      users(:aaron).reload
      new_email = users(:aaron).email

      new_email.should_not == old_email
      new_email.should == "new@new.new"
    end

    it 'should allow a user to change their password if they supplied two matching passwords' do
      old_password = users(:aaron).crypted_password

      put :update,
        :id => users(:aaron).id,
        :user => {
          :password => "newpassword",
          :password_confirmation => "newpassword"
        }

      users(:aaron).reload
      new_password = users(:aaron).crypted_password

      new_password.should_not == be_nil
      new_password.should_not == old_password
    end

    it 'should not allow a user to change their password if they supplied two different passwords' do
      old_password = users(:aaron).crypted_password

      put :update,
        :id => users(:aaron).id,
        :user => {
          :password => "onepassword",
          :password_confirmation => "twopassword"
        }

      users(:aaron).reload
      new_password = users(:aaron).crypted_password

      new_password.should == old_password
    end
  end

  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire', :password_confirmation => 'quire' }.merge(options)
  end
end