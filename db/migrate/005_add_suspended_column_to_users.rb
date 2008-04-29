class AddSuspendedColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :suspended, :boolean, :default => false
  end

  def self.down
    remove_column :users, :suspended
  end
end
