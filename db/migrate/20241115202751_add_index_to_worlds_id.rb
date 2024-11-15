class AddIndexToWorldsId < ActiveRecord::Migration[6.0]
  def change
    add_index :worlds, :world_id, unique: true
  end
end
