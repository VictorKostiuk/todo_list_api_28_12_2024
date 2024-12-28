class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.references :list, null: false, foreign_key: true
      t.string :name
      t.string :description
      t.datetime :deadline

      t.timestamps
    end
  end
end
