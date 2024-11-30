class World < ActiveRecord::Base
  before_create :generate_unique_world_id

  has_many :user_worlds
  has_many :users, through: :user_worlds
  has_many :squares, dependent: :destroy
  has_many :characters, dependent: :destroy

  def storm
    # Get all squares in the world
    squares_to_shuffle = squares.to_a

    # Shuffle the squares
    shuffled_squares = squares_to_shuffle.shuffle

    # Update each square with new coordinates
    shuffled_squares.each_with_index do |square, index|
      new_x = index % 6  # Assuming a 6x6 grid
      new_y = index / 6
      square.update(x: new_x, y: new_y)
    end
  end

  private

  def generate_unique_world_id
    self.world_id = SecureRandom.hex(10) # Generates a 20-character hex string
  end
end
