class AddIndexToUserWorldsId < ActiveRecord::Migration[6.0]
  def change
      add_index :user_worlds, :user_world_id, unique: true
  end
end
