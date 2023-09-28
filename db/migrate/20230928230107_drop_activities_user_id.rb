class DropActivitiesUserId < ActiveRecord::Migration[6.1]
  def change
    remove_column :activities, :user_id, :integer, null: true
  end
end
