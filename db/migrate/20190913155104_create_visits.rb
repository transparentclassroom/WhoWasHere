class CreateVisits < ActiveRecord::Migration[6.0]
  def change
    create_table :visits do |t|
      t.integer "user_id"
      t.integer "school_id"
      t.datetime "start_at"
      t.datetime "stop_at"
      t.integer "seconds"
      t.integer "start_activity_id"
      t.integer "stop_activity_id"

      t.index ["user_id"]
    end
  end
end
