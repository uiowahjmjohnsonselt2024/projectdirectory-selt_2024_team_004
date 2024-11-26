class CharactersController < ApplicationController
  before_action :set_current_user
  def new
  end

  def index

  end

  def create

  end

  def destroy

  end

  def update_position
    # Params should contain the target x and y from the frontend
    @character = Character.first || Character.create(x_coord: 0, y_coord: 0)
    @character.update(x_coord: params[:x], y_coord: params[:y])

    render json: { x: @character.x_coord, y: @character.y_coord }
  end
end