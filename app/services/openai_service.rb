class OpenaiService
    def self.client
      @client ||= OpenAI::Client.new(
        access_token: ENV['OPENAI_API_KEY'],
        log_errors: Rails.env.development?
      )
    end
  
    def self.generate_terrain_image(terrain_type, context = {})
      Rails.logger.info "Generating terrain image for #{terrain_type}"
      
      # Get adjacent terrains for better context
      adjacent = context[:adjacent_terrains] || {}
      
      response = client.images.generate(
        parameters: {
          model: "dall-e-3",
          prompt: terrain_image_prompt(terrain_type, adjacent),
          size: "1024x1024",
          quality: "standard",
          n: 1
        }
      )
      
      url = response.dig('data', 0, 'url')
      Rails.logger.info "Generated image URL: #{url}"
      url
    rescue StandardError => e
      Rails.logger.error "Error generating terrain image: #{e.message}"
      nil
    end
  
    private
  
    def self.terrain_image_prompt(terrain_type, adjacent)
      # Base descriptions for each terrain type
      base_descriptions = {
        "water" => {
          base: "deep blue ocean water section",
          edge: "water must perfectly continue into"
        },
        "desert" => {
          base: "sandy desert terrain section",
          edge: "desert must perfectly continue into"
        },
        "forest" => {
          base: "dense forest terrain section",
          edge: "forest must perfectly continue into"
        },
        "plains" => {
          base: "grassy plains terrain section",
          edge: "grassland must perfectly continue into"
        }
      }

      # Build precise edge matching instructions
      transitions = []
      adjacent.each do |direction, adj_terrain|
        next unless adj_terrain
        
        edge_desc = case direction
        when :north
          "The top edge MUST perfectly continue the #{adj_terrain} pattern from above, as if cut from the same map"
        when :south
          "The bottom edge MUST perfectly continue the #{adj_terrain} pattern from below, as if cut from the same map"
        when :east
          "The right edge MUST perfectly continue the #{adj_terrain} pattern from the right, as if cut from the same map"
        when :west
          "The left edge MUST perfectly continue the #{adj_terrain} pattern from the left, as if cut from the same map"
        end
        transitions << edge_desc
      end

      transition_context = transitions.join('. ') + '.'

      base_prompt = "Create a section of a larger map showing #{base_descriptions[terrain_type][:base]}. " +
                   "#{transition_context} " +
                   "This is just ONE PIECE of a larger 6x6 map grid - imagine cutting a large map into squares. " +
                   "Style: Fantasy map with clear, bold terrain features. " +
                   "Colors: deep blue for water, sandy beige for desert, " +
                   "dark green for forest, light green for plains. " +
                   "NO grid overlay. NO borders. NO individual map elements. " +
                   "This should look like a clean cut section of a larger continuous map. " +
                   "The terrain must flow naturally across tile boundaries as if it was one large map that was cut into pieces. " +
                   "Think of this as one square piece of a larger puzzle - " +
                   "when assembled with other pieces, it should create one seamless, continuous map."
      
      Rails.logger.info "Generated prompt: #{base_prompt}"
      base_prompt
    end
  end