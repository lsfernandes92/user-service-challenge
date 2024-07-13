class AddIndexToEmailAndFullNameOnUsers < ActiveRecord::Migration[7.1]
  def up
    add_index :users, :email
    add_index :users, :full_name
  end

  def down
    remove_index :users, :email
    remove_index :users, :full_name
  end
end
