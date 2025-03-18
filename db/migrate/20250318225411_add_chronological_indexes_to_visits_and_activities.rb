class AddChronologicalIndexesToVisitsAndActivities < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  def change
    add_index :visits, :stop_at, order: { stop_at: :desc }, algorithm: :concurrently, if_not_exists: true
    add_index :activities, :created_at, order: { created_at: :desc }, algorithm: :concurrently, if_not_exists: true
  end
end
