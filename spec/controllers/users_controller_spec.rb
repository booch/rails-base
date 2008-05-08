require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe UsersController do
  fixtures :users
  fixtures :roles

  describe 'when logged in as an admin' do
    before(:each) do
      login_as(:iamjwc)
    end

    it 'should display a list of the users' do
      get :index
      response.should_not be_redirect
    end
  
    it 'should be able to create new users' do
      lambda do
        create_user
        response.should be_redirect
      end.should change(User, :count).by(1)
    end

    it 'should be able to suspend and unsuspend a user' do
      user = users(:activated)
      user.suspended?.should be_false

      put :suspend, :id => user.id

      user.reload
      user.suspended?.should be_true

      put :unsuspend, :id => user.id

      user.reload
      user.suspended?.should be_false
    end

    it 'should be able to send a user a password reset code' do
      user = users(:activated)
      user.password_reset_code.should be_nil

      put :reset_password, :id => user.id

      user.reload
      user.password_reset_code.should_not be_nil
    end
  end
  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire', :password_confirmation => 'quire' }.merge(options)
  end
end