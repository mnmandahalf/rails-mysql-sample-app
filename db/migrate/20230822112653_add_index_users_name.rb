class AddIndexUsersName < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :name, type: :fulltext
  end
end
