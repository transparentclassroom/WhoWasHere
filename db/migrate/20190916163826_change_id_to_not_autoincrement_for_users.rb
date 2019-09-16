class ChangeIdToNotAutoincrementForUsers < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :id, :null
  end
end
