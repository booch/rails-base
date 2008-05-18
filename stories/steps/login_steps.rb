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

  Then "the flash should say '$text'" do |text|
      response.should have_text(/#{text}/i)
  end

  Given "has a password of '$password'" do |password|
    @user.password = password
    @user.password_confirmation = password
    @user.save!
  end

  Then "I should be authenticated" do
    session[:user_id].should_not be_nil
    session[:user_id].should be_an(Integer) # NOTE: Might actually be a String, due to the way sessions are handled.
    user = User.find(session[:user_id])
    user.login.should == @user.login
  end
  
  Then "I should NOT be authenticated" do
    session[:user_id].should be_nil
  end
  
end
