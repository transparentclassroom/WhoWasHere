class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.integer :last_activity_id
      t.integer :last_visit_id

      t.string :email, null: false
    end
  end
end
