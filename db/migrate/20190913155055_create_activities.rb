class CreateActivities < ActiveRecord::Migration[6.0]
  def change
    create_table :activities do |t|
      t.integer "user_id", null: false
      t.integer "school_id", null: false
      t.integer "visit_id"
      t.string "name", limit: 255, null: false
      t.string "activity_type", null: false
      t.datetime "created_at"

      t.index ["user_id", "activity_type"]
      t.index ["visit_id"]
    end
  end
end
