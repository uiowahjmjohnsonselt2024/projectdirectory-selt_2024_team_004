class AddIndexToCharactersId < ActiveRecord::Migration[6.0]
  def change
    add_index :characters, :character_id, unique: true
  end
end
