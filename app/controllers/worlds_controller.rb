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
    terrain_types = ["forest", "mountain", "lake", "village", "plain", "desert"]

    6.times do |y|
      6.times do |x|
        begin
          terrain = terrain_types.sample
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
            terrain: terrain,
            code: generate_fallback_code(x, y, terrain)
          )
        end
      end
    end

    actual_count = world.squares.where(world_id: world.id).count
    puts "Final square count for world #{world.id}: #{actual_count}"
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
              content: "You are a JavaScript expert creating interconnected map tiles. Each tile should smoothly connect with its neighbors, avoiding abrupt transitions or floating elements like suns. The terrain should flow naturally across tile boundaries."
            },
            { 
              role: "user", 
              content: "Generate JavaScript code to draw a #{terrain} tile (105x105 canvas) that connects with its neighbors. Only output the code. Do not put in any explanations or comments. Do not create a new canvas or append elements:
              North: #{adjacent_terrains[:north] || 'unknown'}
              South: #{adjacent_terrains[:south] || 'unknown'}
              East: #{adjacent_terrains[:east] || 'unknown'}
              West: #{adjacent_terrains[:west] || 'unknown'}
              
              Use only the 'ctx' variable. Ensure terrain features align with edges and avoid standalone elements like suns or clouds. Use consistent colors and patterns."
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
