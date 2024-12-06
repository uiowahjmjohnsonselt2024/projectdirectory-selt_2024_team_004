class WorldsController < ApplicationController
  before_action :set_current_user

  def landing
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
      @image_path = "#{params[:gender]}_#{params[:preload]}_#{params[:role]}.png"
      UserWorld.create!(user: @current_user, world: @world, user_role: params[:role], owner: true)
      Character.create!(world: @world, x_coord: 0, y_coord: 0, image_code: @image_path) # Set starting position to top-left

      # Only generate the initial three squares
      generate_initial_squares(@world, 0, 0)

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
    
    store
    @user = current_user
    @user_world ||= UserWorld.find_by(user_id: @user.id)
    @world ||= @user_world.world
    @character ||= @world.characters.first

    # Create empty squares for the entire 6x6 grid with no code
    (0..5).each do |y|
      (0..5).each do |x|
        @world.squares.find_or_create_by!(
          x: x,
          y: y,
          square_id: SecureRandom.hex(10),
          world_id: @world.id,
          state: "inactive",
          terrain: ["forest", "desert", "water", "plains"].sample  # Assign random terrain but no code
        )
      end
    end

    # Generate content only for the initial three squares
    generate_initial_squares(@world, 0, 0)
    @squares = @world.squares.order(:y, :x)

    render 'squares/landing'
  end

  def generate_square
    world = World.find(params[:world_id])
    x = params[:x].to_i
    y = params[:y].to_i

    return render json: { error: 'Invalid coordinates' } if x < 0 || y < 0 || x >= 6 || y >= 6
    return render json: { square: world.squares.find_by(x: x, y: y) } if world.squares.exists?(x: x, y: y)

    # Randomly select terrain with equal probability
    terrain = ["forest", "desert", "water", "plains"].sample
    
    # Get adjacent terrains for context
    adjacent_terrains = get_adjacent_terrains(world, x, y)
    drawing_commands = OpenaiService.generate_terrain_code(terrain, adjacent_terrains: adjacent_terrains)

    square = world.squares.create!(
      square_id: SecureRandom.hex(10),
      world_id: world.id,
      x: x,
      y: y,
      state: "active",
      terrain: terrain,
      code: drawing_commands
    )

    render json: { square: square }
  end

  private

  def generate_initial_squares(world, x_coord, y_coord)
    # Only generate these three positions initially
    positions = [
      [x_coord, y_coord],     # Current position (0,0)
      [x_coord + 1, y_coord], # Right (1,0)
      [x_coord, y_coord + 1]  # Below (0,1)
    ]

    positions.each do |x, y|
      square = world.squares.find_by(x: x, y: y)
      next unless square
      
      terrain = square.terrain # Use the already assigned terrain
      adjacent_terrains = get_adjacent_terrains(world, x, y)
      drawing_commands = OpenaiService.generate_terrain_code(terrain, adjacent_terrains: adjacent_terrains)
      
      square.update!(
        state: "active",
        code: drawing_commands
      )
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

  def api_call
    client = OpenAI::Client.new(
      access_token: "access_token_goes_here",
      log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
    )
  end

  def store
    @user = current_user
    @currency = @user.default_currency || 'USD'
    @prices = StoreService.fetch_prices(@user)
    puts "User: #{@user}"
    puts "Currency: #{@currency}"
    puts "Prices: #{@prices}"
  end

  def current_user
    @current_user ||= User.find_by id: params[:user_id]
  end
end
