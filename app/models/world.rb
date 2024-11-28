class World < ActiveRecord::Base
  before_create :generate_unique_world_id

  has_many :user_worlds
  has_many :users, through: :user_worlds
  has_many :squares, dependent: :destroy

  private

  def generate_unique_world_id
    self.world_id = SecureRandom.hex(10) # Generates a 20-character hex string
  end
end
