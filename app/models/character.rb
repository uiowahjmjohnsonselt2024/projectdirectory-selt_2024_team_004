class Character < ActiveRecord::Base
  before_create :generate_unique_character_id
  attr_accessor :x_coord, :y_coord, :target_x, :target_y, :speed

  private
  def generate_unique_character_id
    self.character_id = SecureRandom.hex(10) # Generates a 20-character hex string
  end


  belongs_to :world
end
