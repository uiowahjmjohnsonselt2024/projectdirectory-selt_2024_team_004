class AddStateToSquares < ActiveRecord::Migration[6.0]
  def change
    add_column :squares, :state, :string
  end
end
