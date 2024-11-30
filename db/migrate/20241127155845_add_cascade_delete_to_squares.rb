class AddCascadeDeleteToSquares < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :squares, :worlds
    add_foreign_key :squares, :worlds, on_delete: :cascade
  end
end
