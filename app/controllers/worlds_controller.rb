class WorldsController < ApplicationController
  before_action :set_current_user

  def new
    @world_id = params[:world_id]
  end

  def index
    puts params
    puts @current_user.name
    if @current_user
      @user_worlds = @current_user.user_worlds
    else
      flash[:alert] = "Please log in to view your worlds."
      redirect_to login_path
    end
  end

  def create
    puts "Form submitted successfully!"
    @world = World.new(last_played: DateTime.now, progress: 0)
  
    if @world.save
      @world.update(world_name: "World #{@world.id}")
      UserWorld.create!(user: @current_user, world: @world, user_role: user_roles, owner: true)
  
      # Generate squares with progress tracking
      generate_squares_for_world(@world)
  
      flash[:notice] = "World created successfully!"
      redirect_to worlds_path
    else
      flash[:alert] = "Failed to create world. Please try again."
      render :new
    end
  end
  

  def destroy
    puts params.inspect
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
      @image_key = "#{@gender}_#{@preload}_#{@role}"
      @image_path = "/assets/images/#{@image_key}.png"
    else
      @image_path = "/assets/images/1_1_1.png"
    end
  end

  def start_game
    @world = World.find(params[:id])
    @squares = @world.squares.order(:y, :x)
  
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
    world.squares.where(world_id: world.id).destroy_all
    
    require 'openai'
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    
    # Create a 6x6 terrain map (not 3x3)
    terrain_map = generate_terrain_map(6, 6)
    
    # Debug output
    puts "Generating #{terrain_map.length} rows x #{terrain_map[0].length} columns"
    
    6.times do |y|
      6.times do |x|
        begin
          terrain = terrain_map[y][x]
          puts "Generating square at (#{x}, #{y}) with terrain: #{terrain}"
          generate_single_square(world, x, y, terrain, client)
          puts "Created square at position (#{x}, #{y}) for world #{world.id}"
          sleep(0.1)
        rescue => e
          puts "Error creating square at (#{x}, #{y}): #{e.message}"
          world.squares.create!(
            square_id: SecureRandom.hex(10),
            world_id: world.id,
            x: x,
            y: y,
            state: "inactive",
            terrain: terrain || "plain",
            code: generate_fallback_code(x, y, terrain || "plain")
          )
        end
      end
    end
  end
  

  def generate_terrain_map(width, height)
    terrain_types = ["forest", "mountain", "lake", "plain"]
    map = Array.new(6) { Array.new(6) }  # Force 6x6 grid
    
    # Start with plains as base terrain
    map.each_index do |y|
      map[y].each_index do |x|
        map[y][x] = "plain"
      end
    end

    # Generate mountain range (4 squares)
    mountain_start_x = rand(width - 1)
    mountain_start_y = rand(height - 1)
    [[0,0], [0,1], [1,0], [1,1]].each do |dx, dy|
      if (mountain_start_x + dx) < width && (mountain_start_y + dy) < height
        map[mountain_start_y + dy][mountain_start_x + dx] = "mountain"
      end
    end

    # Generate forest (2-3 squares)
    forest_squares = []
    forest_start_x = rand(width)
    forest_start_y = rand(height)
    [[0,0], [0,1], [1,0]].each do |dx, dy|
      if (forest_start_x + dx) < width && (forest_start_y + dy) < height
        next if map[forest_start_y + dy][forest_start_x + dx] == "mountain"
        map[forest_start_y + dy][forest_start_x + dx] = "forest"
      end
    end

    # Generate lake (2 squares)
    lake_squares = []
    lake_start_x = rand(width)
    lake_start_y = rand(height)
    [[0,0], [1,0]].each do |dx, dy|
      if (lake_start_x + dx) < width && (lake_start_y + dy) < height
        next if map[lake_start_y + dy][lake_start_x + dx] == "mountain" ||
                map[lake_start_y + dy][lake_start_x + dx] == "forest"
        map[lake_start_y + dy][lake_start_x + dx] = "lake"
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
              content: "You are a JavaScript expert creating cohesive terrain tiles. Each terrain type should blend naturally with its neighbors and be part of a larger feature. Mountains are tall and rocky, forests are dense with trees, lakes are deep blue water, and plains are grassy fields."
            },
            { 
              role: "user", 
              content: "Generate JavaScript code to draw a #{terrain} tile (105x105 canvas) that connects with its neighbors:
              North: #{adjacent_terrains[:north] || 'unknown'}
              South: #{adjacent_terrains[:south] || 'unknown'}
              East: #{adjacent_terrains[:east] || 'unknown'}
              West: #{adjacent_terrains[:west] || 'unknown'}
              
              Use only the 'ctx' variable. The terrain should be part of a larger #{terrain} feature and blend naturally with adjacent tiles.
              For mountains: Use grays and browns, show rocky peaks and slopes
              For forests: Use various greens, show dense tree coverage
              For lakes: Use blues, show water ripples or waves
              For plains: Use yellows and light greens, show grass patterns
              
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
end
