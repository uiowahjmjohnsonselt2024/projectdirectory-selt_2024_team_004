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

      # Generate squares with OpenAI API
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
    puts 'params'
    puts params

    @new_world = @world

    redirect_to some_other_path, notice: "Your adventure begins!"
  end

  private

  def generate_squares_for_world(world)
    puts 'generate_squares_for_world exists'
    return if world.squares.exists? # Prevent duplicate square generation
  
    puts "Starting square generation..."  # Debug line
  
    require 'openai'
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  
    terrain_types = ["forest", "mountain", "lake", "village", "plain", "desert"]
  
    6.times do |y|
      6.times do |x|
        terrain = terrain_types.sample
        puts "Generating square #{x},#{y} with terrain: #{terrain}"  # Debug line
  
        prompt = <<~PROMPT
          Create JavaScript code that:
          1. Creates a 32x32 canvas element
          2. Draws a #{terrain} in pixel art style
          3. Uses specific colors (e.g., greens for forests, blues for lakes)
          4. Returns only the JavaScript code that creates and draws on the canvas. DO NOT RETURN AN EXPLANATION, ONLY THE CODE.
          
          Example format:
          function drawSquare#{x}_#{y}(containerId) {
            const canvas = document.createElement('canvas');
            canvas.width = 32;
            canvas.height = 32;
            const ctx = canvas.getContext('2d');
            // Drawing code here
            document.getElementById(containerId).appendChild(canvas);
          }
        PROMPT
  
        puts "Sending request to OpenAI..."  # Debug line
        
        begin  # Add error handling
          response = client.chat(
            parameters: {
              model: "gpt-4",
              messages: [{ role: "user", content: prompt }],
              temperature: 0.7
            }
          )
          
          puts "Got response from OpenAI"  # Debug line
          code = response.dig("choices", 0, "message", "content")
          puts "Generated code:"  # Debug line
          puts code  # This will show the actual code
          
          world.squares.create!(
            x: x + 1,
            y: y + 1,
            state: "inactive",
            terrain: terrain,
            code: code.strip
          )
          puts "Created square in database"  # Debug line
          
        rescue => e
          puts "Error occurred: #{e.message}"  # Debug line for errors
          puts e.backtrace  # Show the full error trace
        end
      end
    end
  end
end
