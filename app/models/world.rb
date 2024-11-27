class World < ActiveRecord::Base
  before_create :generate_unique_world_id

  private

  def generate_unique_world_id
      self.world_id = SecureRandom.hex(10) # Generates a 20-character hex string
  end

  has_many :user_worlds
  has_many :characters, dependent: :destroy
  has_many :users, :through => :user_worlds
  has_many :squares
end
