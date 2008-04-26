class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += ''  
    @body[:url]  = "#{HOST}/user/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += ''
    @body[:url]  = "Visit #{HOST}!"
  end
  
  def forgot_password(user)
    setup_email(user)
    @subject    += ''
    @body[:url]  = "#{HOST}/reset_password/#{user.password_reset_code}" 
  end

  def reset_password(user)
    setup_email(user)
    @subject    += 'Your password has been reset.'
  end   
  
  protected

  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = %()
    @subject     = ""
    @sent_on     = Time.now
    @body[:user] = user
  end
end
