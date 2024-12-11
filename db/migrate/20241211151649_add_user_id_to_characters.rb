class AddUserIdToCharacters < ActiveRecord::Migration[6.0]
  def up
    # First add the column as nullable
    add_reference :characters, :user, null: true, foreign_key: true

    # Update existing records
    execute <<-SQL
      UPDATE characters
      SET user_id = (
        SELECT user_worlds.user_id
        FROM user_worlds
        WHERE user_worlds.world_id = characters.world_id
        LIMIT 1
      )
    SQL

    # Now make it non-nullable
    change_column_null :characters, :user_id, false
  end

  def down
    remove_reference :characters, :user
  end
end
