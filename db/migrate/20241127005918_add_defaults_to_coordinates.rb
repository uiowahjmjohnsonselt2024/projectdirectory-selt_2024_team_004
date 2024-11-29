class AddDefaultsToCoordinates < ActiveRecord::Migration[6.0]
  def change
    change_column_default :characters, :x_coord, 10
    change_column_default :characters, :y_coord, 10
  end
end
