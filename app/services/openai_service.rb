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
    end
  
    def self.terrain_system_prompt
      <<~PROMPT
        You are a JavaScript canvas expert creating connected terrain patterns.
        
        TERRAIN RULES:
        - Forest: Deep green (#228B22), must connect with adjacent forest tiles to form areas of 4 connected tiles. Add darker green (#006400) tree shapes.
        - Desert: Single sandy color (#DEB887) for base, use slightly darker sand color (#C19A6B) for dune lines only. Must be single isolated tiles, no direct adjacency.
        - Water: Ocean blue (#1E90FF), must connect with 2 other water tiles to form groups of 3.
        - Plains: Light green (#90EE90), must connect with exactly one other plains tile to form pairs. Add darker green grass details.
        
        CONNECTION RULES:
        - Terrains must seamlessly connect with matching adjacent tiles
        - Edges must align perfectly with neighboring tiles
        - Use smooth transitions between different terrain types
        - Maintain consistent base colors within each terrain type
        
        DESERT SPECIFIC:
        - Use ONLY #DEB887 as the base color for ALL desert tiles
        - Draw dune lines using #C19A6B (slightly darker sand color)
        - Dune lines should be curved and natural looking
        - No variation in the base color between desert tiles
        - Only the dune line patterns should differ
        
        CRITICAL:
        - Do not create canvas or context variables
        - Use only the provided 'ctx' variable
        - Generate only the drawing code
      PROMPT
    end
  
    def self.terrain_user_prompt(terrain_type, context)
      base_prompt = "Generate JavaScript code for a #{terrain_type} tile (105x105 canvas)."
  
      # Add specific rules based on terrain type and adjacent tiles
      case terrain_type
      when "forest"
        base_prompt += "\nThis forest tile must connect with adjacent forest tiles to form a larger forest area covering 4 connected tiles."
        base_prompt += "\nUse deep green (#228B22) as the base color and add darker green (#006400) tree shapes."
      when "desert"
        base_prompt += "\nThis must be an isolated desert tile with no direct desert neighbors."
        base_prompt += "\nUse ONLY #DEB887 as the base color and #C19A6B for dune line details."
        base_prompt += "\nDraw curved dune lines to show sand patterns, but keep the base color consistent."
      when "water"
        base_prompt += "\nThis water tile must connect with two other water tiles to form a group of three."
        base_prompt += "\nUse ocean blue (#1E90FF)."
      when "plains"
        base_prompt += "\nThis plains tile must connect with exactly one other plains tile to form a pair."
        base_prompt += "\nUse light green (#90EE90) as base and add darker grass detail lines."
      end
  
      # Include context about adjacent terrains to inform connections
      if context.any?
        base_prompt += "\nAdjacent terrains:"
        context.each do |direction, terrain|
          base_prompt += "\n#{direction.capitalize}: #{terrain || 'unknown'}"
        end
      end
  
      base_prompt += "\nEnsure seamless connections with matching adjacent terrains."
      base_prompt += "\nUse only the 'ctx' variable to draw."
      base_prompt += "\nDo not create canvas or context variables."
      
      base_prompt
    end
  end