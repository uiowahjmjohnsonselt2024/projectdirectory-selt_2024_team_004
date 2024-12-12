class CharactersController < ApplicationController
  before_action :set_character, only: [:save_coordinates, :update_shards]
  before_action :current_user

  def save_coordinates
    @character = Character.find(params[:id])
    if @character.update(x_coord: params[:x], y_coord: params[:y])
      render json: { success: true, message: 'Coordinates saved successfully.' }
    else
      render json: { success: false, errors: @character.errors.full_messages }, status: :unprocessable_entity
    end
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

  private

  def set_character
    @character = Character.find(params[:id])
  end

  def current_user
    @current_user ||= User.find_by id: params[:user_id]
  end

  def character_params
    params.require(:character).permit(:name, :image_code, :user_world_id)
  end
end
