class CharactersController < ApplicationController
  before_action :set_current_user
  def save_coordinates
    @character = Character.find(params[:id])
    if @character.update(x_coord: params[:x], y_coord: params[:y])
      puts "Update succeeded"
    else
      puts "Update failed: #{@character.errors.full_messages}"
    end
  end
end