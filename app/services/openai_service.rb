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
      # Generate a unique function name
      function_name = "drawSquare_#{Time.now.to_i}_#{SecureRandom.hex(4)}"
      
      # Remove markdown code blocks
      formatted_code = raw_code
        .gsub(/```(javascript|js)?\n?/, '')
        .gsub(/```/, '')

      # Wrap the code in a function that takes a square ID
      <<~JAVASCRIPT
        window['#{function_name}'] = function(squareId) {
          const canvas = document.createElement('canvas');
          canvas.width = 105;
          canvas.height = 105;
          const ctx = canvas.getContext('2d');
          
          #{formatted_code}
          
          const square = document.getElementById(squareId);
          if (square) {
            // Remove any existing canvas
            const existingCanvas = square.querySelector('canvas');
            if (existingCanvas) {
              existingCanvas.remove();
            }
            square.appendChild(canvas);
          }
        };
      JAVASCRIPT
    end
  
    def self.terrain_system_prompt
      <<~PROMPT
        You are a JavaScript canvas expert creating terrain tiles. Each tile must seamlessly connect with adjacent tiles.
  
        TERRAIN TYPES AND COLORS:
        - Water: Deep blue (#1E90FF) with subtle wave patterns
        - Desert: Sandy tan (#D2B48C) with small dune patterns
        - Forest: Dark green (#228B22) with scattered tree patterns
        - Plains: Light green (#90EE90) with grass patterns
  
        RULES FOR ALL TERRAINS:
        1. Use exactly 105x105 canvas size
        2. Features must align perfectly at edges
        3. Use consistent colors within each terrain type
        4. Create natural, organic patterns
        5. No straight lines or geometric shapes
        6. Ensure seamless connections with adjacent tiles
        7. Use subtle patterns that don't overwhelm
        8. Keep consistent scale across all tiles
  
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