class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :oid
      t.string :user_name
      t.string :password
      t.integer :enabled
      
    end
    add_index :users, :user_name, unique: true
    add_index :users, :oid
  end

  def self.down
    remove_index :users, :user_name
    remove_index :users, :oid
    drop_table :users
  end
end
