class AddGoogleTasksListIdToLists < ActiveRecord::Migration[7.1]
  def change
    add_column :lists, :google_tasks_list_id, :string
  end
end
