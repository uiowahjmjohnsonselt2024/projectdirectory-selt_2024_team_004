class SquaresController < ApplicationController

  def landing
    store
    @user ||= User.find_by id: params[:user_id]
    @world ||= World.find_by id: params[:world_id]
    @character ||= Character.find_by world_id: @world.id
    @game_result = params[:game_result] || false

    unless @world
      flash[:alert] = "No world selected"
      redirect_to worlds_path and return
    end

    @squares = Square.where(world_id: @world.id).order(:y, :x)
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
      puts "Teleporting..."
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

  def activate_square
    @square = Square.find_by(square_id: params[:square_id])
    @character = Character.find(params[:character_id])

    if @square.activate_square(@character)
      render json: {
        success: true,
        message: "Square activated successfully!",
        new_shards: @character.shards,
        square: {
          id: @square.square_id,
          code: @square.code,
          terrain_type: @square.terrain_type
        }
      }
    else
      render json: {
        success: false,
        message: "Failed to activate square. Make sure you have enough shards."
      }, status: :unprocessable_entity
    end
  end

  def generate_square_code
    x = params[:x]
    y = params[:y]
    
    # Generate terrain code here
    terrain_types = ["forest", "desert", "water", "plains"]
    terrain = terrain_types.sample
    
    # You can implement your own terrain generation logic here
    code = "ctx.fillStyle = '#eee'; ctx.fillRect(0, 0, 105, 105);"
    
    render json: { success: true, code: code }
  rescue => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  private

  def store
    @user = current_user
    @currency = @user.default_currency || 'USD'
    @prices = StoreService.fetch_prices(@user.default_currency)
    puts "User: #{@user}"
    puts "Currency: #{@currency}"
    puts "Prices: #{@prices}"
  end

  def current_user
    @current_user ||= User.find_by id: params[:user_id]
  end
end
