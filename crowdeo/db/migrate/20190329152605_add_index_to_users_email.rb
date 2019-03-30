class AddIndexToUsersEmail < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :email, unique: true
    add_index :users, :nick_name, unique: true
  end
end
