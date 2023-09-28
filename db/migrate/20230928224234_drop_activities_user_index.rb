class DropActivitiesUserIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index :activities, :user_id
    change_column :activities, :user_id, :integer, null: true
  end
end
