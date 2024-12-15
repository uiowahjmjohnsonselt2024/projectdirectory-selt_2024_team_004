class CharactersController < ApplicationController
  before_action :set_character, only: [:save_coordinates, :update_shards]
  before_action :current_user

  def save_coordinates
    Rails.logger.info "Starting save_coordinates with params: #{params.inspect}"
    
    @character = Character.find(params[:id])
    Rails.logger.info "Found character: #{@character.inspect}"

    if @character.update(x_coord: params[:x], y_coord: params[:y])
      Rails.logger.info "Successfully updated character position"
      
      # Get the square at the new coordinates
      square = Square.find_by(
        world_id: @character.world_id,
        x: @character.x_coord,
        y: @character.y_coord
      )

      # Broadcast both the character movement and terrain info
      channel = "game_channel_#{@character.world_id}"
      
      # First broadcast character movement
      movement_message = {
        type: 'character_moved',
        character_id: @character.id,
        x: @character.x_coord,
        y: @character.y_coord
      }
      
      # Then broadcast terrain info if square exists and is active
      if square && square.state == 'active'
        terrain_message = {
          type: 'terrain_updated',
          square_id: square.square_id,
          terrain: square.terrain,
          state: square.state,
          code: square.code
        }
        
        # Broadcast both messages
        ActionCable.server.broadcast(channel, movement_message)
        ActionCable.server.broadcast(channel, terrain_message)
      else
        # Just broadcast movement if no active square
        ActionCable.server.broadcast(channel, movement_message)
      end

      render json: { 
        success: true,
        message: 'Position updated and broadcast successful',
        x: @character.x_coord,
        y: @character.y_coord
      }
    else
      Rails.logger.error "Failed to update character: #{@character.errors.full_messages}"
      render json: { 
        success: false, 
        errors: @character.errors.full_messages 
      }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Error in save_coordinates: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { 
      success: false, 
      error: "#{e.class}: #{e.message}" 
    }, status: :internal_server_error
  end

  def update_shards
    puts "Received params: #{params.inspect}"
    character = Character.find(params[:id])
    shards_being_bought = params[:shards].to_i
    price = params[:price].to_f
    credit_card = {card_number: params[:card_number], cvv: params[:cvv], expiration_date: params[:expiration_date]}

    result = FakePaymentService.charge(price, credit_card)

    if result[:status] == 'Success'
      puts character.shards
      character.update!(shards: character.shards + shards_being_bought)

      render json: {
        success: true,
        new_shards: character.shards,
        transaction_id: result[:transaction_id]
      }
    else
      render json: { success: false, error: result[:error] }, status: :unprocessable_entity
    end
  end

  def new
    @user_world = UserWorld.find(params[:user_world_id])
    @character = Character.new
  end

  def create
    @character = Character.new(character_params)
    if @character.save
      flash[:notice] = "Character created successfully!"
      redirect_to worlds_path
    else
      flash.now[:alert] = "Error creating character."
      render :new
    end
  end

  def update
    @character = Character.find(params[:id])
    
    if @character.update(character_params)
      render json: {
        success: true,
        message: "Position saved successfully!"
      }
    else
      render json: {
        success: false,
        message: "Failed to save position"
      }, status: :unprocessable_entity
    end
  end

  private

  def set_character
    @character = Character.find_by(id: params[:id])
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def character_params
    params.require(:character).permit(:x_coord, :y_coord, :shards)
  end
end
