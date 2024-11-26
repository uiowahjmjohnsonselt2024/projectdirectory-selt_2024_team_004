class CharactersController < ApplicationController
  before_action :set_current_user
  def update_position
    @character.update(x_coord: params[:x], y_coord: params[:y])

    render json: { x: @character.x_coord, y: @character.y_coord }
  end
end