class AddActivitiesToVisits < ActiveRecord::Migration[6.0]
  def change
    add_column :visits, :activities, :jsonb, null: false, default: []

    add_timestamps :visits, null: true
  end
end

