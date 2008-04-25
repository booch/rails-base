class AddPasswordResetToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :password_reset_code, :string, :limit => 40
    add_column :users, :password_reset_code_expires_at, :datetime
  end

  def self.down
    remove_column :users, :password_reset_code_expires_at
    remove_column :users, :password_reset_code
  end
end
