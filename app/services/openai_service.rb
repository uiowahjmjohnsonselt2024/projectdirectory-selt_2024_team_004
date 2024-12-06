class OpenaiService
    def self.client
      @client ||= OpenAI::Client.new(
        access_token: ENV['OPENAI_API_KEY'],
        log_errors: Rails.env.development?
      )
    end
  
    def self.generate_terrain_image(terrain_type, context = {})
      Rails.logger.info "Generating terrain image for #{terrain_type}"
      response = client.images.generate(
        parameters: {
          model: "dall-e-3",
          prompt: terrain_image_prompt(terrain_type, context),
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
  
    def self.terrain_image_prompt(terrain_type, context)
      base_prompt = case terrain_type
      when "water"
        "A seamless top-down view of ocean water, pure water texture without any patterns or shapes"
      when "desert"
        "A seamless top-down view of desert sand, pure sand texture without any patterns or shapes"
      when "forest"
        "A seamless top-down view of dense forest canopy, pure forest texture without any patterns or shapes"
      when "plains"
        "A seamless top-down view of grass plains, pure grass texture without any patterns or shapes"
      end

      base_prompt + ", flat texture, no borders, no shapes, no patterns, seamless tile, photorealistic"
    end
  end