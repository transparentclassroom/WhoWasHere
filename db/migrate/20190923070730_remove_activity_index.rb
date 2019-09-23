class RemoveActivityIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index :activities, [:user_id, :activity_type]
    add_index :activities, [:user_id]
  end
end
