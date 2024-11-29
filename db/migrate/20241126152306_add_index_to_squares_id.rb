class AddIndexToSquaresId < ActiveRecord::Migration[6.0]
  def change
    add_index :squares, :square_id, unique: true
  end
end
