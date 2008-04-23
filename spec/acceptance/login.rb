
describe 'User logs in' do
  before(:all)
    visits '/user/logout'
  end

  before(:each)
    visits '/user/login'
  end

  after(:each)
    visits '/user/logout'
  end

  describe 'with a valid username and password' do
    before(:each) do
      fills_in 'Username', :with => 'test'
      fills_in 'Password', :with => 'password'
      clicks_button 'Login'
    end

    it 'should authenticate the user' do
      session[:user_id].should be_an(Integer) # NOTE: Might actually be a String, due to the way sessions are handled.
      user = User.find(session[:user_id])
      user.username.should == 'test'
    end

    it 'should redirect the user to the home page'
  end

  describe 'with an invalid username' do
    before(:each) do
      fills_in 'Username', :with => 'invalid_username'
      fills_in 'Password', :with => 'password'
      clicks_button 'Login'
    end

    it 'should NOT authenticate the user' do
      session[:user_id].should be_nil
    end

    it 'should redirect the user back to the login page'

    it 'should let the user know that they entered an incorrect username or password' do
      response.should have_text(/incorrect username or password/i)
    end
  end

  describe 'with an invalid password' do
    before(:each) do
      fills_in 'Username', :with => 'test'
      fills_in 'Password', :with => 'invalid_password'
      clicks_button 'Login'
    end

    it 'should NOT authenticate the user' do
      session[:user_id].should be_nil
    end

    it 'should redirect the user back to the login page'

    it 'should let the user know that they entered an incorrect username or password' do
      response.should have_text(/incorrect username or password/i)
    end
  end
end


describe 'User needs to reset password'
  before(:all)
    visits '/user/logout'
  end

  before(:each) do
    visits '/user/login'
    clicks_link 'Forgot password'
  end

  it "should get redirected to '/user/forgot_password'"

  describe 'and fills_in a valid username' do
    before(:each) do
      fills_in 'Username', :with => 'test'
      clicks_button 'Email me my password'
    end

    it 'should tell the user that his/her password to the email account on record'

    it 'should email the user his/her password'
  end

  describe 'and fills_in an invalid username' do
    before(:each) do
      fills_in 'Username', :with => 'invalid_username'
      clicks_button 'Email me my password'
    end
    # NOTE: This is a security problem -- it allows attackers to find valid usenames.
    it 'should tell the user that the username is invalid'

    it 'should NOT email the user his/her password'
  end
end
