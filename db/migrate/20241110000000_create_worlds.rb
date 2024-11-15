class CreateWorlds < ActiveRecord::Migration[6.0]
  def change
    create_table :worlds do |t|
      t.string "world_id"
      t.string 'world_name'
      t.datetime 'last_played'
      t.integer 'progress'
    end
  end
end
