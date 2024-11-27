class CharactersController < ApplicationController
  before_action :set_current_user
  def update_position
    if @character.update(x_coord: params[:x].to_i, y_coord: params[:y].to_i)
      render json: { x: @character.x_coord, y: @character.y_coord }
    else
      render json: { error: @character.errors.full_messages }, status: :unprocessable_entity
    end
  end
end