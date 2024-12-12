class Square < ActiveRecord::Base
  belongs_to :world
  
  before_create :generate_unique_square_id
  before_save :ensure_single_treasure

  def activate_square(character)
    return false unless character.shards >= 10
    
    transaction do
      # Deduct shards from character
      character.update!(shards: character.shards - 10)
      
      # Generate terrain and code
      terrain_types = ["forest", "desert", "water", "plains"]
      terrain = terrain_types.sample
      
      # Get adjacent squares' terrain for context
      adjacent_squares = {
        north: world.squares.find_by(x: x, y: y - 1)&.terrain,
        south: world.squares.find_by(x: x, y: y + 1)&.terrain,
        east: world.squares.find_by(x: x + 1, y: y)&.terrain,
        west: world.squares.find_by(x: x - 1, y: y)&.terrain
      }
      
      # Generate code using OpenAI
      generated_code = OpenaiService.generate_terrain_code(terrain, adjacent_squares)
      
      # Update square with new terrain and code
      update!(
        active: true,
        terrain_type: terrain,
        code: generated_code
      )
    end
    
    true
  rescue => e
    Rails.logger.error("Error activating square: #{e.message}")
    false
  end

  private

  def generate_unique_square_id
    self.square_id = SecureRandom.hex(10)
  end

  def ensure_single_treasure
    if treasure_changed? && treasure
      world.squares.where.not(id: id).update_all(treasure: false)
    end
  end
end