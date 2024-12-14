class SquaresController < ApplicationController

  def landing
    store
    @user ||= User.find_by id: params[:user_id]
    @world ||= World.find_by id: params[:world_id]
    @character ||= Character.find_by world_id: @world.id
    @game_result = params[:game_result] || false
    @square_id = params[:square_id]

    Rails.logger.debug "Landing params: #{params.inspect}"
    Rails.logger.debug "Game result: #{@game_result}, Square ID: #{@square_id}"

    unless @world
      Rails.logger.error "No world found for ID: #{params[:world_id]}"
      flash[:alert] = "No world selected"
      redirect_to worlds_path and return
    end

    # Handle minigame victory
    if @game_result == 'true' && @square_id.present?
      Rails.logger.info "=== Starting minigame victory handling ==="
      Rails.logger.info "Looking for square with square_id: #{@square_id}"
      
      @square = Square.find_by(square_id: @square_id)
      
      if @square
        Rails.logger.info "Found square: #{@square.inspect}"
        Rails.logger.info "Square current state: #{@square.state}"
        
        if @square.state == 'inactive'
          Rails.logger.info "Square is inactive, proceeding with terrain generation"
          
          begin
            Square.transaction do
              # Add 1 shard to character for winning the game
              @character.update!(shards: (@character.shards || 0) + 1)
              Rails.logger.info "Added 1 shard to character. New total: #{@character.shards}"

              # Generate terrain
              terrain_types = ["forest", "desert", "water", "plains"]
              terrain = terrain_types.sample
              Rails.logger.info "Selected terrain type: #{terrain}"
              
              # Get adjacent squares for context
              adjacent_squares = {
                north: Square.find_by(world_id: @square.world_id, x: @square.x, y: @square.y - 1)&.terrain,
                south: Square.find_by(world_id: @square.world_id, x: @square.x, y: @square.y + 1)&.terrain,
                east: Square.find_by(world_id: @square.world_id, x: @square.x + 1, y: @square.y)&.terrain,
                west: Square.find_by(world_id: @square.world_id, x: @square.x - 1, y: @square.y)&.terrain
              }
              Rails.logger.info "Adjacent squares: #{adjacent_squares.inspect}"

              # Generate code using OpenAI
              Rails.logger.info "Generating terrain code..."
              generated_code = OpenaiService.generate_terrain_code(terrain, adjacent_squares)
              Rails.logger.info "Generated code length: #{generated_code&.length}"
              
              update_result = @square.update!(
                state: 'active',
                terrain: terrain,
                code: generated_code
              )
              
              Rails.logger.info "Square update successful: #{update_result}"
              Rails.logger.info "Updated square attributes: #{@square.reload.attributes}"
            end
          rescue => e
            Rails.logger.error "Error during square update: #{e.message}"
            Rails.logger.error e.backtrace.join("\n")
            raise e
          end
        else
          Rails.logger.info "Square is already active, skipping terrain generation"
        end
      else
        Rails.logger.error "No square found with square_id: #{@square_id}"
      end
    else
      Rails.logger.info "Not a minigame victory or no square_id present"
      Rails.logger.info "game_result: #{@game_result.inspect}"
      Rails.logger.info "square_id: #{@square_id.inspect}"
    end

    @squares = Square.where(world_id: @world.id).order(:y, :x)
    Rails.logger.info "Total squares loaded for world: #{@squares.count}"
  end

  def pay_shards
    Rails.logger.info "Pay shards params: #{params.inspect}"
    
    @character = Character.find_by(id: params[:character_id])
    @square = Square.find_by(id: params[:square_id])

    Rails.logger.info "Character found: #{@character.inspect}"
    Rails.logger.info "Square found: #{@square.inspect}"

    if @character.nil? || @square.nil?
      Rails.logger.error "Character or square not found"
      render json: {
        success: false,
        message: "Character or square not found"
      }
      return
    end

    # Calculate shard cost based on distance
    current_x = @character.x_coord.to_i
    current_y = @character.y_coord.to_i
    target_x = @square.x.to_i
    target_y = @square.y.to_i
    
    # Different costs based on square state
    if @square.state == "inactive"
      shard_cost = 10  # Cost to activate new square
    else
      # Cost based on distance for moving between active squares
      shard_cost = (target_x - current_x).abs + (target_y - current_y).abs
    end

    Rails.logger.info "Shard cost calculation: #{shard_cost} (from #{current_x},#{current_y} to #{target_x},#{target_y})"

    # Check if character has enough shards
    if @character.shards >= shard_cost
      Rails.logger.info "Character has enough shards. Updating position..."
      
      Square.transaction do
        # If square is inactive, activate it
        if @square.state == "inactive"
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
        end

        # Update character position and shards
        @character.update!(
          shards: @character.shards - shard_cost,
          x_coord: target_x,
          y_coord: target_y
        )
      end

      render json: {
        success: true,
        new_shards: @character.shards,
        square: {
          id: @square.id,
          code: @square.code,
          terrain: @square.terrain
        },
        message: "Successfully moved to new position"
      }
    else
      Rails.logger.info "Not enough shards (has: #{@character.shards}, needs: #{shard_cost})"
      render json: {
        success: false,
        message: "Not enough shards (need #{shard_cost})"
      }
    end

  rescue => e
    Rails.logger.error "Error in pay_shards: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: {
      success: false,
      message: e.message
    }
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
