class UserObserver < ActiveRecord::Observer
  def after_create(user)
    return unless ENV['RAILS_ENV'] == 'production'
    UserNotifier.deliver_signup_notification(user)
  end

  def after_save(user) 
    return unless ENV['RAILS_ENV'] == 'production'
    UserNotifier.deliver_activation(user) if user.recently_activated?
    UserNotifier.deliver_forgot_password(user) if user.recently_forgot_password?
    UserNotifier.deliver_reset_password(user) if user.recently_reset_password?   
  end
end
