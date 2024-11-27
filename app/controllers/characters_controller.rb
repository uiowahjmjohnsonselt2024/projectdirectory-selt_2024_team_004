class CharactersController < ApplicationController
  before_action :set_current_user
  def update_coordinates
    character = Character.find(params[:id]) # Ensure the character ID is sent with the request
    if character.update(x_coord: params[:x_coord], y_coord: params[:y_coord])
      head :ok # Respond with success
    else
      render json: { error: 'Failed to update coordinates' }, status: :unprocessable_entity
    end
  end
end