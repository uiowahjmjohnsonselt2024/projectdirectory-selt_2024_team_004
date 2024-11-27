class AddPixelArtToSquares < ActiveRecord::Migration[6.0]
  def change
    add_column :squares, :pixel_art, :text
  end
end
