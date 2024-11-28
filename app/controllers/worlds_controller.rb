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
  
      # Use only one method to generate squares
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
  
    if @squares.count != 9
      flash[:alert] = "Regenerating squares for this world"
      @squares.destroy_all
      generate_squares_for_world(@world)
      @squares = @world.squares.reload.order(:y, :x)
    end
    puts 'world id'
    puts @world.id
    render 'squares/landing', locals: { world_id: @world.id }
  end
  

  private

  def generate_squares_for_world(world)
    world.squares.where(world_id: world.id).destroy_all
    
    require 'openai'
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    terrain_types = ["forest", "mountain", "lake", "village", "plain", "desert"]

    3.times do |y|
      3.times do |x|
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
        canvas.width = 32;
        canvas.height = 32;
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
        ctx.fillRect(0, 0, 32, 32);
        document.getElementById(containerId).appendChild(canvas);
      }
    JAVASCRIPT
  end

  def generate_single_square(world, x, y, terrain, client)
    # Check if square exists for THIS world
    return if world.squares.exists?(x: x, y: y)

    begin
      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            { role: "system", content: "You are a JavaScript expert. Generate code to draw a #{terrain} terrain on a 32x32 canvas. The canvas and context are already created. Use only the provided 'ctx' context." },
            { role: "user", content: "Write JavaScript code to draw a #{terrain} on the canvas. Use only the 'ctx' variable to draw. Do not create new canvas or append elements. Do not declare ctx again." }
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
          canvas.width = 32;
          canvas.height = 32;
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
end
