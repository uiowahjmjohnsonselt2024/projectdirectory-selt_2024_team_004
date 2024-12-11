class Character < ActiveRecord::Base
  before_create :generate_unique_character_id

  private
  def generate_unique_character_id
    self.character_id = SecureRandom.hex(10) # Generates a 20-character hex string
  end

  belongs_to :world
  belongs_to :user
end
