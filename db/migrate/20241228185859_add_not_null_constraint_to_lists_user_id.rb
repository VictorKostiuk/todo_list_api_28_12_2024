class AddNotNullConstraintToListsUserId < ActiveRecord::Migration[7.1]
  def change
    change_column_null :lists, :user_id, false
  end
end
