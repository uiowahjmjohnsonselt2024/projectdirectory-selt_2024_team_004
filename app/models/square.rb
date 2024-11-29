class UserWorld < ActiveRecord::Base

    before_create :generate_unique_square_id
  
    private
  
    def generate_unique_square_id
        self.square_id = SecureRandom.hex(10) # Generates a 20-character hex string
    end
  
    belongs_to :world
  
end