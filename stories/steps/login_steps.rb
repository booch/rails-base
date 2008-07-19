module InstanceVariableHelpers
  def set_ivar(type, name, obj)
    instance_variable_set ivar_name(type, name), obj
  end
  def get_ivar(type, name)
    returning instance_variable_get(ivar_name(type, name)) do |obj|
      yield obj if block_given?
    end
  end
  private
  def ivar_name(type, name)
    "@#{type}_#{name.gsub(/[ -]/,'_').gsub('&','and')}"
  end
end
include InstanceVariableHelpers

module Spec
  module Rails
    module Matchers
      class BeA  #:nodoc:
        def initialize(klass)
          @klass = klass
        end
        def matches?(obj)
          @obj = obj
          @obj.is_a? @klass
        end
        def failure_message
          "object expected to be a(n) #{@klass.name} but was a(n) #{@obj.class.name}\n"
        end
        def negative_failure_message
          "object expected to NOT be a(n) #{@klass.name} but was a(n) #{@klass.name} (#{@obj.class.name})\n"
        end
        def description
          'be an instance of (a subclass of) the given class'
        end
      end
      def be_a(klass)
        BeA.new(klass)
      end
      def be_an(klass)
        BeA.new(klass)
      end

    end
  end
end


steps_for(:login) do

  Given "I am logged in as '$username'" do |username|
    @user = User.find(:first, :conditions => {:login => username}) ||
            User.create!(:login => username, :email => 'test@example.com',
                         :password => 'password', :password_confirmation => 'password')
    visits '/session/login'
    fills_in :login, :with => username
    fills_in :password, :with => 'password'
    clicks_button
  end

  Given "the '$username' user exists" do |username|
    @user = User.find(:first, :conditions => {:login => username}) ||
            User.create!(:login => username, :email => 'test@example.com',
                         :password => 'password', :password_confirmation => 'password')
  end

  Given "the '$username' user does not exist" do |username|
    User.find_by_login(username).should be_nil
  end

  Given "has been activated" do
    @user.activate!
    @user.save!
  end

  Given "has not been activated" do
    @user.activated_at = nil
    @user.save!
  end

  Given "has $number failed login attempts" do |number|
    @user.failed_attempts = number
    @user.save!
  end

  Given "has a password of '$password'" do |password|
    @user.password = password
    @user.password_confirmation = password
    @user.save!
  end

  Then "the flash should say '$text'" do |text|
    response.should have_text(/#{text}/i)
  end

  Then "I should be authenticated" do
    session[:user_id].should_not be_nil
    session[:user_id].should be_an(Integer)
    user = User.find(session[:user_id])
    user.login.should == @user.login
  end
  
  Then "I should NOT be authenticated" do
    session[:user_id].should be_nil
  end
  
  Then "I should be logged out" do
    session[:user_id].should be_nil
  end

  Then "my account should have a recent last_login_at timestamp" do
    user = User.find(session[:user_id])
    (Time.now - user.last_login_at).should < 2 # Allow 2 seconds
  end

  Then "the '$username' account should be locked" do |username|
    User.find_by_login(username).should be_suspended
  end


end
