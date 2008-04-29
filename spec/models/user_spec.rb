require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe User do
  fixtures :users

  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end
    
    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
    end
  end

  before(:each) do
    users(:quentin).activate!
  end

  it 'requires login' do
    lambda do
      u = create_user(:login => nil)
      u.errors.on(:login).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password' do
    lambda do
      u = create_user(:password => nil)
      u.errors.on(:password).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_user(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires email' do
    lambda do
      u = create_user(:email => nil)
      u.errors.on(:email).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'resets password' do
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate('quentin', 'new password').should == users(:quentin)
  end

  it 'does not rehash password' do
    users(:quentin).update_attributes(:login => 'quentin2')
    User.authenticate('quentin2', 'test').should == users(:quentin)
  end

  it 'authenticates user' do
    User.authenticate('quentin', 'test').should == users(:quentin)
  end

  it 'sets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).forget_me
    users(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  describe 'that is suspended' do
    it 'should not be able to login' do
      User.authenticate(users(:suspended).login, 'test').should be_nil

      users(:suspended).unsuspend!
      User.authenticate(users(:suspended).login, 'test').should_not be_nil
    end
  end

  describe 'when first created' do
    before(:each) do
      @u = create_user
    end

    it 'should not be able to login until gets activated' do
      User.authenticate('quire', 'quire').should == nil

      @u.activate!
      User.authenticate('quire', 'quire').should_not == nil
    end

    it 'should have an activation code' do
      @u.activation_code.should_not == nil
    end

    it 'should not have an activation time' do
      @u.activated_at.should == nil
    end

    it 'should not have a password reset code or expiration time' do
      @u.password_reset_code.should == nil
      @u.password_reset_code_expires_at.should == nil
    end
  end

  describe 'that forgot password' do
    before(:each) do
      @u = create_user
    end

    it 'should be able to generate a password reset code' do
      @u.password_reset_code.should be_nil
      @u.password_reset_code_expires_at.should be_nil

      @u.forgot_password

      @u.password_reset_code.should_not be_nil
      @u.password_reset_code_expires_at.should_not be_nil
    end

    it 'should not be able to reset password if it is not done within 48 hours' do
      @u.forgot_password

      @u.reset_password(48.hours.from_now).should be_false
    end

    it 'should be able to reset password if it is done within 48 hours' do
      @u.forgot_password

      @u.reset_password(Time.now).should be_true
    end

    it 'should be able to be found with User.find_by_password_reset_code for 48 hours' do
      u = create_user
      u.forgot_password

      code = u.password_reset_code
      u2 = User.find_by_password_reset_code(code)

      u2.should_not be_nil
      u.id.should == u2.id
      u2.password_reset_code_expires_at.should > Time.now
    end
  end

protected
  def create_user(options = {})
    record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    record.save
    record
  end
end
