class CreateCharacters < ActiveRecord::Migration[6.0]
  def change
    create_table "characters", force: :cascade do |t|
      t.string "character_id"
      t.string "image_code"
      t.integer "shards"
      t.integer "x_coord"
      t.integer "y_coord"
      t.references :world, null: false, foreign_key: true
    end
  end
end
