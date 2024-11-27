class CreateSquares < ActiveRecord::Migration[6.0]
  def change
    create_table :worlds do |t|
      t.string "square_id"
      t.string 'world_name'
      t.references :world, null: false, foreign_key: true
      t.integer 'x'
      t.integer 'y'
      t.string 'weather'
      t.boolean 'treasure'
      t.string 'game'
      t.string 'monsters'
    end
  end
end
