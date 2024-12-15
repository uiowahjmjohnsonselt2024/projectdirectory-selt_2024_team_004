class UserWorld < ActiveRecord::Base

  before_create :generate_unique_user_world_id

  private

  def generate_unique_user_world_id
    self.user_world_id = SecureRandom.hex(10) # Generates a 20-character hex string
  end

  belongs_to :user
  belongs_to :world

end
