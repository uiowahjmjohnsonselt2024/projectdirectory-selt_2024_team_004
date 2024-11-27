class World < ActiveRecord::Base
  before_create :generate_unique_world_id
  after_create :generate_squares
  private

  def generate_unique_world_id
      self.world_id = SecureRandom.hex(10) # Generates a 20-character hex string
  end

    has_many :user_worlds
    has_many :users, :through => :user_worlds
    has_many :squares, dependent: :destroy

    def generate_squares
      art_types = ["sand_dune", "forest", "mountain"] # Define your themes
      (1..36).each do |i|
        squares.create(
          x: (i % 6) + 1,
          y: (i / 6) + 1,
          state: "inactive",
          pixel_art: generate_pixel_art(art_types.sample) # Assign a random art type
        )
      end
    end
    
  
    def generate_pixel_art(theme)
      client = OpenAI::Client.new
      prompt = "Create a 6x6 pixel art representation of a #{theme} using symbols like '#', '~', and '.'"
      response = client.completions(
        parameters: {
          model: "text-davinci-003",
          prompt: prompt,
          max_tokens: 150
        }
      )
      response["choices"][0]["text"].strip
    rescue => e
      Rails.logger.error "OpenAI Error: #{e.message}"
      "ERROR: Art not generated"
    end
end
