class Square < ActiveRecord::Base

    before_create :generate_unique_square_id
    before_save :ensure_single_treasure
    private
  
    def generate_unique_square_id
        self.square_id = SecureRandom.hex(10) # Generates a 20-character hex string
    end
  
    belongs_to :world
  
    def ensure_single_treasure
      if treasure_changed? && treasure
        # If this square is being set to have treasure, remove treasure from all other squares
        world.squares.where.not(id: id).update_all(treasure: false)
      end
    end
end