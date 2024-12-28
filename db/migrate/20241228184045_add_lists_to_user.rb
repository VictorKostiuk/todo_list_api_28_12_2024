class AddListsToUser < ActiveRecord::Migration[7.1]
  def change
    add_reference :lists, :user, foreign_key: true
  end
end
