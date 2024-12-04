class OpenaiService
    def self.client
      @client ||= OpenAI::Client.new(
        access_token: ENV['OPENAI_API_KEY'],
        log_errors: Rails.env.development?
      )
    end
  
    def self.generate_terrain_code(terrain_type, context = {})
      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            {
              role: "system",
              content: terrain_system_prompt
            },
            {
              role: "user",
              content: terrain_user_prompt(terrain_type, context)
            }
          ],
          temperature: 0.7
        }
      )
      
      raw_code = response.dig('choices', 0, 'message', 'content')
      format_js_code(raw_code)
    rescue StandardError => e
      Rails.logger.error("Error generating terrain code: #{e.message}")
      nil
    end
  
    private
  
    def self.format_js_code(raw_code)
      raw_code
        .gsub(/```(javascript|js)?\n?/, '')
        .gsub(/```/, '')
        .gsub(/const canvas = document\.createElement\('canvas'\);/, '')
        .gsub(/const ctx = canvas\.getContext\('2d'\);/, '')
    end
  
    def self.terrain_system_prompt
      <<~PROMPT
        You are a JavaScript canvas expert creating a minimalist ocean with small sandy desert islands. EVERY water tile must be EXACTLY identical.
  
        OCEAN BACKGROUND:
        - Fill ENTIRE canvas with EXACTLY #1E90FF
        - Every single water tile must be identical
        - NO variation in the blue color
        - NO patterns or lines
        - Just solid blue color
        
        DESERT ISLANDS (when present):
        - Color: Muted sandy tan (#D2B48C)
        - Single small organic shape with curved edges
        - Must take up only 20-40% of tile maximum
        - NO straight lines or edges anywhere
        - Edges must be smooth bezier curves
        - Natural, irregular island shapes
        - Must be surrounded by water
        
        CRITICAL RULES:
        1. EVERY water tile must be pure #1E90FF only
        2. Desert must take up LESS than 40% of any tile
        3. NO straight lines in island shapes
        4. Islands must have only curved boundaries
        5. Perfect alignment between adjacent tiles
        6. Water must be completely solid color
        7. NO variation in background color
        8. Islands must be small and well-spaced
  
        IMPORTANT: Only provide the drawing code. Do not create canvas or context variables.
      PROMPT
    end
  
    def self.terrain_user_prompt(terrain_type, context)
      base_prompt = "Generate JavaScript code for a #{terrain_type} tile (105x105 canvas)."
      
      if context[:adjacent_terrains]
        base_prompt += "\nConnect with:"
        context[:adjacent_terrains].each do |direction, terrain|
          base_prompt += "\n#{direction.capitalize}: #{terrain || 'unknown'}"
        end
      end
  
      base_prompt += "\nUse only the 'ctx' variable to draw."
      base_prompt += "\nDo not create canvas or context variables."
      base_prompt += "\nDo not create a function wrapper."
      
      base_prompt
    end
  end