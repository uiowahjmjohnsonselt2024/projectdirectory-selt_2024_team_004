class WorldsController < ApplicationController
  before_action :current_user

  def new
    @world_id = params[:world_id]
    @user_world_id = params[:user_world_id]
    session[:world_id] = @world_id
  end

  def index
    if @current_user
      @user_worlds = @current_user.user_worlds
      @invitations = Invitation.where(receiver_id: @current_user.id, status: 'pending')

      @invited_players = {}
      @user_worlds.each do |user_world|
        world = user_world.world
        # Get all invitations for this world, excluding accepted ones and getting unique emails
        @invited_players[world.id] = Invitation.where(world_id: world.id)
                                           .where.not(status: 'accepted')
                                           .includes(:receiver)
                                           .map { |invitation| invitation.receiver.email }
                                           .uniq
      end

      @world = @user_worlds.first&.world
    else
      flash[:alert] = 'Please log in to view your worlds.'
      redirect_to login_path
    end
  end

  def create
    if params[:user_world_id].present?
      # Handle invited user character creation
      @user_world = UserWorld.find(params[:user_world_id])
      @image_path = "#{params[:gender]}_#{params[:preload]}_#{params[:role]}.png"
      Character.create!(
        world: @user_world.world,
        user: @current_user,
        shards: 10,
        x_coord: 0,
        y_coord: 0,
        image_code: @image_path
      )
    else
      # Handle new world creation
      @world = World.new(
        last_played: DateTime.now,
        progress: 0,
        world_name: params[:world_name]
      )

      if @world.save
        @image_path = "#{params[:gender]}_#{params[:preload]}_#{params[:role]}.png"
        UserWorld.create!(user: @current_user, world: @world, user_role: params[:role], owner: true)
        Character.create!(
          world: @world, 
          user: @current_user, 
          shards: 10,
          x_coord: 0, 
          y_coord: 0, 
          image_code: @image_path
        )

        generate_squares_for_world(@world)
      end
    end

    flash[:notice] = "Character created successfully!"
    redirect_to worlds_path
  end


  def destroy
    begin
      @user_world = UserWorld.find_by(world_id: params[:id], user_id: current_user.id)
      @world = World.find_by(id: params[:id])

      if @user_world&.owner
        # Delete everything if owner
        UserWorld.where(world_id: @world.id).destroy_all
        @world.destroy
        flash[:notice] = "World deleted successfully."
      else
        # Just remove user's association if not owner
        @user_world&.destroy
        flash[:notice] = "Left the world successfully."
      end

      respond_to do |format|
        format.html { redirect_to worlds_path }
        format.json { head :no_content }
      end
    rescue => e
      Rails.logger.error "Error in destroy action: #{e.message}"
      respond_to do |format|
        format.html { redirect_to worlds_path, alert: 'Error processing request.' }
        format.json { render json: { error: e.message }, status: :internal_server_error }
      end
    end
  end

  def start_game
    @world = World.find(params[:id])
    @squares = @world.squares.order(:y, :x)

    store
    @user = current_user
    @user_world = UserWorld.find_by(user_id: @user.id, world_id: @world.id)
    # Find the specific character for this user in this world
    @character = @world.characters.find_by(user_id: @user.id)

    if @squares.count != 36
      flash[:alert] = "Regenerating squares for this world"
      @squares.destroy_all
      generate_squares_for_world(@world)
      @squares = @world.squares.reload.order(:y, :x)
    end

    redirect_to landing_path(world_id: @world.id, user_id: @user.id)
  end

  def generate_square_code
    x = params[:x].to_i
    y = params[:y].to_i
    terrain_types = ["desert", "water", "forest", "plains"]
    terrain = terrain_types.sample

    begin
      square = @world.squares.find_or_initialize_by(x: x, y: y)
      adjacent_terrains = get_adjacent_terrains(@world, x, y)
      code = OpenaiService.generate_terrain_code(terrain, adjacent_terrains)

      if code.present?
        square.update!(terrain: terrain, code: code)
        render json: { success: true, code: code, terrain: terrain }
      else
        render json: { success: false, error: "Failed to generate terrain code" }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Validation error: #{e.message}")
      render json: { success: false, error: "Validation error: #{e.message}" }, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error("Error in generate_square_code: #{e.message}")
      render json: { success: false, error: "Error generating terrain: #{e.message}" }, status: :unprocessable_entity
    end
  end

  def join
    @user_world_id = params[:user_world_id]
  end

  def join_existing
    @user_world = UserWorld.find(params[:user_world_id])
    @image_path = "#{params[:gender]}_#{params[:preload]}_#{params[:role]}.png"

    Character.create!(
      world: @user_world.world,
      user: current_user,
      shards: 10,
      x_coord: 0,
      y_coord: 0,
      image_code: @image_path
    )

    flash[:notice] = "Character created successfully!"
    redirect_to worlds_path
  end

  def pay_shards
    @character = Character.find_by(id: params[:character_id])
    @square = Square.find_by(square_id: params[:square_id])

    if !@character || !@square
      render json: {
        success: false,
        message: "Invalid square/character"
      }, status: :unprocessable_entity
    end

    row_difference = (@square.y - @character.y_coord).abs
    column_difference = (@square.x - @character.x_coord).abs
    shards_cost_for_teleporting = row_difference + column_difference

    if @square.state == "inactive" && @character.shards >= 10
      # Deduct shards and generate terrain
      Square.transaction do
        @character.update!(shards: @character.shards - 10)

        # Generate terrain
        terrain_types = ["forest", "desert", "water", "plains"]
        terrain = terrain_types.sample

        # Get adjacent squares for context
        adjacent_squares = {
          north: Square.find_by(world_id: @square.world_id, x: @square.x, y: @square.y - 1)&.terrain,
          south: Square.find_by(world_id: @square.world_id, x: @square.x, y: @square.y + 1)&.terrain,
          east: Square.find_by(world_id: @square.world_id, x: @square.x + 1, y: @square.y)&.terrain,
          west: Square.find_by(world_id: @square.world_id, x: @square.x - 1, y: @square.y)&.terrain
        }

        # Generate code using OpenAI
        generated_code = OpenaiService.generate_terrain_code(terrain, adjacent_squares)

        @square.update!(
          state: 'active',
          terrain: terrain,
          code: generated_code
        )

        render json: {
          success: true,
          game_result: true,
          new_shards: @character.shards,
          square: {
            id: @square.id,
            code: generated_code,
            terrain_type: terrain
          }
        }
      end
    elsif @square.state == "active" && @character.shards >= shards_cost_for_teleporting
      Square.transaction do
        @character.update!(shards: @character.shards - shards_cost_for_teleporting)
        render json: {
          success: true,
          game_result: true,
          new_shards: @character.shards,
          square: {
            id: @square.id
          }
        }
      end
    else
      render json: {
        success: false,
        message: "Not enough shards"
      }, status: :unprocessable_entity
    end
  end

  def restart
    @world = World.find(params[:id])
    
    World.transaction do
      # First deactivate all squares
      @world.squares.update_all(state: 'inactive', terrain: nil, code: nil)

      # Set up initial three active squares with proper terrain generation
      initial_positions = [[0,0], [1,0], [0,1]]
      initial_positions.each do |x, y|
        square = @world.squares.find_by(x: x, y: y)
        terrain_types = ["forest", "desert", "water", "plains"]
        terrain = terrain_types.sample

        # Get adjacent terrains for context
        adjacent_terrains = {
          north: @world.squares.find_by(x: x, y: y - 1)&.terrain,
          south: @world.squares.find_by(x: x, y: y + 1)&.terrain,
          east: @world.squares.find_by(x: x + 1, y: y)&.terrain,
          west: @world.squares.find_by(x: x - 1, y: y)&.terrain
        }

        # Generate code using OpenAI
        generated_code = OpenaiService.generate_terrain_code(terrain, adjacent_terrains)

        square.update!(
          state: 'active',
          terrain: terrain,
          code: generated_code
        )

        # Broadcast each terrain update
        ActionCable.server.broadcast(
          "game_channel_#{@world.id}",
          {
            type: 'terrain_updated',
            square_id: square.square_id,
            terrain: terrain,
            state: 'active',
            code: generated_code
          }
        )
      end

      # Reset treasure location
      old_treasure = @world.squares.find_by(treasure: true)
      old_treasure.update!(treasure: false) if old_treasure

      valid_squares = @world.squares.where.not(
        x: [0, 1], 
        y: [0, 1]
      ).or(
        @world.squares.where.not(x: 0).where.not(y: 0)
      )
      
      new_treasure_square = valid_squares.sample
      new_treasure_square.update!(treasure: true)

      # Move all characters back to (0,0)
      @world.characters.update_all(x_coord: 0, y_coord: 0)
    end

    # Broadcast the world reset to trigger character movement and page reload
    ActionCable.server.broadcast(
      "game_channel_#{@world.id}",
      {
        type: 'world_restart',
        world_id: @world.id
      }
    )

    render json: { success: true }
  rescue => e
    Rails.logger.error "Error restarting world: #{e.message}"
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  def award_treasure_shards
    @world = World.find(params[:id])
    
    begin
      World.transaction do
        # Award 10 shards to all characters in this world
        @world.characters.each do |character|
          character.update!(shards: character.shards + 10)
        end
        
        render json: {
          success: true,
          message: "Shards awarded to all characters",
          current_user_shards: @world.characters.find_by(user: current_user)&.shards
        }
      end
    rescue => e
      render json: {
        success: false,
        error: e.message
      }, status: :unprocessable_entity
    end
  end

  private

  def generate_squares_for_world(world)
    # Define available terrains
    terrain_types = ["desert", "water", "forest", "plains"]
    js_functions = []

    # Define the initial three squares in the top-left corner
    active_positions = [[0, 0], [1, 0], [0, 1]]

    # Generate the initial three squares with random terrains
    active_positions.each do |x, y|
      # Get random terrain type
      terrain = terrain_types.sample

      # Get adjacent terrains for context
      adjacent_terrains = get_adjacent_terrains(world, x, y)

      # Generate terrain code with context
      drawing_commands = OpenaiService.generate_terrain_code(terrain, adjacent_terrains)

      # Create the function code
      function_code = <<~JAVASCRIPT
        function drawSquare_#{x}_#{y}(containerId) {
          const canvas = document.createElement('canvas');
          canvas.width = 105;
          canvas.height = 105;
          const ctx = canvas.getContext('2d');
          
          #{drawing_commands}
          
          document.getElementById(containerId).appendChild(canvas);
        }
      JAVASCRIPT

      js_functions << function_code

      # Create the square with the generated code
      world.squares.create!(
        square_id: SecureRandom.hex(10),
        world_id: world.id,
        x: x,
        y: y,
        state: "active",
        terrain: terrain,
        code: drawing_commands
      )
    end

    # Create the rest of the grid without code
    remaining_positions = []
    6.times do |y|
      6.times do |x|
        next if active_positions.include?([x, y])
        
        square = world.squares.create!(
          square_id: SecureRandom.hex(10),
          world_id: world.id,
          x: x,
          y: y,
          state: "inactive",
          terrain: "empty",
          treasure: false  # explicitly set to false
        )
        remaining_positions << [x, y]
      end
    end

    # Select a random position for treasure from remaining positions
    treasure_x, treasure_y = remaining_positions.sample
    treasure_square = world.squares.find_by(x: treasure_x, y: treasure_y)
    treasure_square.update!(treasure: true)

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
    return {} unless world.present?

    {
      north: world.squares.find_by(x: x, y: y - 1)&.terrain,
      south: world.squares.find_by(x: x, y: y + 1)&.terrain,
      east: world.squares.find_by(x: x + 1, y: y)&.terrain,
      west: world.squares.find_by(x: x - 1, y: y)&.terrain
    }
  end

  def api_call
    client = OpenAI::Client.new(
      access_token: "access_token_goes_here",
      log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
    )
  end

  def store
    @user = current_user
    @currency = @user&.default_currency || 'USD'
    @prices = StoreService.fetch_prices(@currency)
    @prices = @prices.transform_values(&:to_f)
  end

  def current_user
    @current_user ||= User.find_by id: session[:user_id]
  end
end
