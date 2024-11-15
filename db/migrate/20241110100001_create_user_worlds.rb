class CreateUserWorlds < ActiveRecord::Migration[6.0]
  def change
    create_table :user_worlds do |t|
      t.string "user_world_id"
      t.string 'user_role'
      t.boolean 'owner'
      t.references :user, null: false, foreign_key: true
      t.references :world, null: false, foreign_key: true
    end
  end
end
