class WorldsController < ApplicationController
  before_action :set_current_user

  def landing
    store
    @user_world ||= UserWorld.find_by(user_id: @user.id)
    @world ||= @user_world.world
    @character ||= @world.characters.first
    @character.x_coord ||= 0
    @character.y_coord ||= 27
  end

  def new
    @world_id = params[:world_id]
  end

  def index
    #@worlds parameter will be a list of all the world keys the current user has
    if @current_user
      @user_worlds = @current_user.user_worlds
    else
      flash[:alert] = 'Please log in to view your worlds.'
      redirect_to login_path
    end
  end

  def create
    puts "Form submitted successfully!"
    @world = World.new(
      last_played: DateTime.now, 
      progress: 0,
      world_name: params[:world_name]
    )
  
    if @world.save
      UserWorld.create!(user: @current_user, world: @world, user_role: user_roles, owner: true)
  
      # Generate squares with progress tracking
      generate_squares_for_world(@world)
  
      flash[:notice] = "World '#{@world.world_name}' created successfully!"
      redirect_to worlds_path
    else
      flash[:alert] = "Failed to create world. Please try again."
      render :new
    end
  end
  

  def destroy
    @user_world = UserWorld.find_by(id: params[:id])
    @world = World.find_by(id: @user_world.world_id)

    if @user_world.owner
      UserWorld.where(world_id: @world.id).destroy_all
      @world.destroy
      flash[:notice] = "World '#{@world.world_id}' deleted."
    else
      @user_world.destroy
      flash[:notice] = "World '#{@world.world_id}' removed."
    end
    redirect_to worlds_path
  end

  def user_roles
    @gender = params[:gender]
    @preload = params[:preload]
    @role = params[:role]

    if @gender && @preload && @role
      @image_path = "#{@gender}_#{@preload}_#{@role}.png"
    else
      @image_path = "1_1_1.png"
    end
  end

  def start_game
    @world = World.find(params[:id])
    @squares = @world.squares.order(:y, :x)
  
    store
    @user_world ||= UserWorld.find_by(user_id: @user.id)
    @world ||= @user_world.world
    @character ||= @world.characters.first
    
    # Create a character if none exists
    if @character.nil?
      @character = Character.create!(
        world: @world,
        x_coord: 0,
        y_coord: 27,
        image_code: "default_character.png"  # Set your default image path
      )
    end

    # Set initial coordinates if they're nil
    @character.x_coord ||= 0
    @character.y_coord ||= 27
    @character.save if @character.changed?

    # Add these lines to initialize store-related variables
    @prices = {
      sea_shard: 0.99  # Set your default price here
    }
    @currency = 'USD'  # Set default currency
  
    puts "World ID: #{@world.id}"
    puts "Square count: #{@squares.count}"
  
    if @squares.count != 36
      flash[:alert] = "Regenerating squares for this world"
      @squares.destroy_all
      generate_squares_for_world(@world)
      @squares = @world.squares.reload.order(:y, :x)
    end
    puts 'world id'
    puts @world.id
    render 'squares/landing'
    #, locals: { world_id: @world.id }
  end
  

  private

  def generate_squares_for_world(world)
    require 'openai'
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    
    # Generate 9 unique squares first
    base_squares = []
    
    # Ensure 3-4 desert squares
    water_count = 9 - rand(3..4)
    desert_count = 9 - water_count
    
    # Helper function to format the JavaScript code
    def format_js_code(raw_code)
      cleaned_code = raw_code.gsub(/```(javascript|js)?\n?/, '').gsub(/```/, '')
      cleaned_code = cleaned_code.gsub(/const canvas = document\.createElement\('canvas'\);/, '')
      cleaned_code = cleaned_code.gsub(/const ctx = canvas\.getContext\('2d'\);/, '')
      
      # Just return the drawing commands
      cleaned_code
    end

    # Generate water squares
    water_count.times do |i|
      terrain_type = "lake"
      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            { 
              role: "system", 
              content: "You are a JavaScript canvas expert creating a minimalist ocean with small sandy desert islands. EVERY water tile must be EXACTLY identical.

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

              IMPORTANT: Only provide the drawing code. Do not create canvas or context variables."
            },
            { 
              role: "user", 
              content: "Generate JavaScript code for a #{terrain_type} tile (105x105 canvas).
                Use only the 'ctx' variable to draw a solid #1E90FF background.
                Do not create canvas or context variables.
                Do not create a function wrapper." 
            }
          ],
          temperature: 0.7
        }
      )
      
      raw_code = response.dig('choices', 0, 'message', 'content')
      drawing_commands = format_js_code(raw_code)
      
      base_squares << {
        terrain: terrain_type,
        code: drawing_commands
      }
    end
    
    # Generate desert squares
    desert_count.times do |i|
      terrain_type = "desert"
      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            { 
              role: "system", 
              content: "You are a JavaScript canvas expert creating a minimalist ocean with small sandy desert islands. EVERY water tile must be EXACTLY identical.

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

              IMPORTANT: Only provide the drawing code. Do not create canvas or context variables."
            },
            { 
              role: "user", 
              content: "Generate JavaScript code for a #{terrain_type} tile (105x105 canvas).
                Use only the 'ctx' variable to draw a solid #1E90FF background with a desert island.
                Do not create canvas or context variables.
                Do not create a function wrapper." 
            }
          ],
          temperature: 0.7
        }
      )
      
      raw_code = response.dig('choices', 0, 'message', 'content')
      drawing_commands = format_js_code(raw_code)
      
      base_squares << {
        terrain: terrain_type,
        code: drawing_commands
      }
    end
    
    # Now fill the 6x6 grid using these 9 squares
    js_functions = []
    
    # Randomly choose coordinates for treasure
    treasure_x = rand(6)
    treasure_y = rand(6)
    
    6.times do |y|
      6.times do |x|
        selected_square = base_squares.sample
        
        # Create the function definition
        function_code = <<~JAVASCRIPT
          function drawSquare_#{x}_#{y}(containerId) {
            const canvas = document.createElement('canvas');
            canvas.width = 105;
            canvas.height = 105;
            const ctx = canvas.getContext('2d');
            
            #{selected_square[:code]}
            
            document.getElementById(containerId).appendChild(canvas);
          }
        JAVASCRIPT
        
        js_functions << function_code
        
        world.squares.create!(
          square_id: SecureRandom.hex(10),
          world_id: world.id,
          x: x,
          y: y,
          state: "inactive",
          terrain: selected_square[:terrain],
          code: function_code,
          treasure: (x == treasure_x && y == treasure_y)  # Set treasure for the randomly chosen square
        )
      end
    end
    treasure = world.squares.find_by(treasure: true)
    puts "Treasure is at x: #{treasure.x}" if treasure
    puts "Treasure is at y: #{treasure.y}" if treasure
    # Add a script tag to define all functions at once
    script_tag = <<~HTML
      <script>
        #{js_functions.join("\n\n")}
      </script>
    HTML
    
    # Store the script tag in a place where your view can access it
    @js_functions = script_tag
  end
  

  def generate_terrain_map(width, height)
    terrain_types = ["desert", "lake"]
    map = Array.new(6) { Array.new(6, "lake") }  # Start with lake as base terrain
    total_squares = width * height
    max_desert_squares = (total_squares * 0.25).floor  # Maximum 25% desert tiles
    desert_count = 0
    
    # Helper function to count adjacent desert tiles
    def count_adjacent_desert(map, x, y)
      count = 0
      # Check all 8 adjacent squares
      [[-1,-1], [-1,0], [-1,1], [0,-1], [0,1], [1,-1], [1,0], [1,1]].each do |dx, dy|
        check_x = x + dx
        check_y = y + dy
        if check_x.between?(0, 5) && check_y.between?(0, 5)
          count += 1 if map[check_y][check_x] == "desert"
        end
      end
      count
    end

    # Helper function to check if adding desert would create too many adjacent deserts
    def would_create_too_many_adjacent?(map, x, y)
      # First check the proposed position
      return true if count_adjacent_desert(map, x, y) >= 3
      
      # Then check all adjacent positions to ensure we won't create too many
      [[-1,-1], [-1,0], [-1,1], [0,-1], [0,1], [1,-1], [1,0], [1,1]].each do |dx, dy|
        check_x = x + dx
        check_y = y + dy
        if check_x.between?(0, 5) && check_y.between?(0, 5)
          # Temporarily add the desert and check
          map[y][x] = "desert"
          too_many = count_adjacent_desert(map, check_x, check_y) > 3
          map[y][x] = "lake"  # Reset
          return true if too_many
        end
      end
      false
    end

    # Helper function to check if a position is valid for an island
    def is_valid_island_position?(map, x, y, width, height)
      return false if x < 0 || x >= width || y < 0 || y >= height
      return false if map[y][x] != "lake"
      return false if would_create_too_many_adjacent?(map, x, y)
      
      # Check immediate neighbors for spacing
      [[-1,0], [1,0], [0,-1], [0,1]].each do |dx, dy|
        check_x = x + dx
        check_y = y + dy
        if check_x.between?(0, width-1) && check_y.between?(0, height-1)
          return false if map[check_y][check_x] != "lake"
        end
      end
      true
    end

    # Create 4-5 desert islands (well-spaced, max 3 adjacent)
    5.times do
      break if desert_count >= max_desert_squares
      
      attempts = 0
      while attempts < 30
        x = rand(width)
        y = rand(height)
        if is_valid_island_position?(map, x, y, width, height)
          map[y][x] = "desert"
          desert_count += 1
          break
        end
        attempts += 1
      end
    end

    map
  end
  

  def generate_fallback_code(x, y, terrain)
    <<~JAVASCRIPT
      function drawSquare_#{x}_#{y}(containerId) {
        const canvas = document.createElement('canvas');
        canvas.width = 105;
        canvas.height = 105;
        const ctx = canvas.getContext('2d');
        ctx.fillStyle = '#{
          case terrain
          when "lake" then "#4444FF"
          when "forest" then "#44FF44"
          when "mountain" then "#8B4513"
          when "village" then "#808080"
          when "plain" then "#FFFF44"
          else "#F4A460" # desert
          end
        }';
        ctx.fillRect(0, 0, 105, 105);
        document.getElementById(containerId).appendChild(canvas);
      }
    JAVASCRIPT
  end

  def generate_single_square(world, x, y, terrain, client)
    return if world.squares.exists?(x: x, y: y)

    adjacent_terrains = get_adjacent_terrains(world, x, y)
    
    begin
      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            { 
              role: "system", 
              content: "You are a JavaScript canvas expert creating a minimalist ocean with small sandy desert islands. EVERY water tile must be EXACTLY identical.

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
              8. Islands must be small and well-spaced"
            },
            { 
              role: "user", 
              content: "Generate JavaScript code for a #{terrain} tile (105x105 canvas) that connects with:
              North: #{adjacent_terrains[:north] || 'unknown'}
              South: #{adjacent_terrains[:south] || 'unknown'}
              East: #{adjacent_terrains[:east] || 'unknown'}
              West: #{adjacent_terrains[:west] || 'unknown'}
            
                
                Use only the 'ctx' variable. The terrain should be part of a larger #{terrain} feature and blend naturally with adjacent tiles.
                
                Ensure features align at edges and maintain consistent style across tiles.
                
                Do not create a new canvas or append elements, canvas is already created. Make sure to add all parantheses ) after argument list, do not put in any explanations or comments. Only output the code."
              }
            ],
            temperature: 0.7
          }
        )
        
        raw_code = response.dig('choices', 0, 'message', 'content')
        sanitized_code = raw_code.gsub(/```(javascript|js)?\n?/, '').gsub(/```/, '').gsub(/const ctx = canvas\.getContext\('2d'\);/, '')

        function_name = "drawSquare_#{x}_#{y}"
        
        formatted_code = <<~JAVASCRIPT
          function #{function_name}(containerId) {
            const canvas = document.createElement('canvas');
            canvas.width = 105;
            canvas.height = 105;
            const ctx = canvas.getContext('2d');
            
            #{sanitized_code}
            
            document.getElementById(containerId).appendChild(canvas);
          }
        JAVASCRIPT

        # Create square with explicit world association
        world.squares.create!(
          square_id: SecureRandom.hex(10),
          world_id: world.id,
          x: x,
          y: y,
          state: "inactive",
          terrain: terrain,
          code: formatted_code
        )
      rescue => e
        puts "Error generating square: #{e.message}"
        unless world.squares.exists?(x: x, y: y)
          world.squares.create!(
            square_id: SecureRandom.hex(10),
            world_id: world.id,
            x: x,
            y: y,
            state: "inactive",
            terrain: terrain,
            code: generate_fallback_code(x, y, terrain)
          )
        end
      end
    end

  def get_adjacent_terrains(world, x, y)
    {
      north: world.squares.find_by(x: x, y: y - 1)&.terrain,
      south: world.squares.find_by(x: x, y: y + 1)&.terrain,
      east: world.squares.find_by(x: x + 1, y: y)&.terrain,
      west: world.squares.find_by(x: x - 1, y: y)&.terrain
    }
  end

  def store
    @user = current_user
    @currency = @user.default_currency || 'USD'
    @prices = StoreService.fetch_prices(@user)
  end
  
  def api_call
    client = OpenAI::Client.new(
      access_token: "access_token_goes_here",
      log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
    )
  end
  def current_user
    @current_user ||= User.find_by id: params[:user_id]
  end
end
