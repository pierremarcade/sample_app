class AddPasswordToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :encrypted_password, :string
  end
  def self.down
    remove_column :users, :encrypted_password
  end
end
