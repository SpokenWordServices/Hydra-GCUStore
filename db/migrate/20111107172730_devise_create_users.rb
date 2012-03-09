class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
#cjn      t.cas_authenticatable
#cjn      t.string :email
#cjn      t.timestamps
#cjn reinstate
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable
#cjn add username to match cas_table
      t.string :username

      # t.encryptable
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable
      t.timestamps
    end

    add_index :users, :username, :unique => true
    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
    # add_index :users, :authentication_token, :unique => true
  end

  def self.down
    drop_table :users
  end
end
