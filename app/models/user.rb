require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  has_and_belongs_to_many :roles

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false

  before_save :encrypt_password
  before_create :make_activation_code
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    # hide records with a nil activated_at
    # hide records that are suspended
    u = self.find :first, :conditions => ['login = ? and activated_at IS NOT NULL and (suspended = ? or suspended IS NULL)', login, false]
    u && u.authenticated?(password) ? u : nil
  end

  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    self.save(false)
  end

  def activated?
    !!activated_at
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def self.find_by_password_reset_code(code)
    return if code.nil?

    conds = { :password_reset_code => code }
    u = self.find(:first, :conditions => conds)

    u unless u.nil? || Time.now > u.password_reset_code_expires_at
  end

  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end

  def reset_password(current_date = Time.now)
    expiration_date = self.password_reset_code_expires_at

    self.password_reset_code = nil
    self.password_reset_code_expires_at = nil

    # If the password is not reset within the window, then
    # the password should not be reset.
    if current_date > expiration_date
      return false
    else
      @reset_password = true
    end
  end

  def recently_reset_password?
    @reset_password
  end

  def recently_forgot_password?
    @forgotten_password
  end

  def has_role?(role_in_question)
    @_list ||= self.roles.collect(&:name)
    return true if @_list.include?("admin")
    (@_list.include?(role_in_question.to_s) )
  end

  def suspend!
    self.update_attribute(:suspended, true)
  end

  def unsuspend!
    self.update_attribute(:suspended, false)
  end

  protected

  def make_password_reset_code
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    self.password_reset_code_expires_at = 48.hours.from_now
    self.save(false)
  end

  # If you're going to use activation, uncomment this too
  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
    
  def password_required?
    crypted_password.blank? || !password.blank? || self.new_record?
  end
    
    
end
