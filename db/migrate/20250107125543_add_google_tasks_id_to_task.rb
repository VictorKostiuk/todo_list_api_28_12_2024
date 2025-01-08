class AddGoogleTasksIdToTask < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :google_task_id, :string
  end
end
