class SquaresController < ApplicationController
  def landing
    @world_id = params[:world_id]
    
    unless @world_id
      flash[:alert] = "No world selected"
      redirect_to worlds_path and return
    end
    
    @squares = Square.where(world_id: @world_id).order(:y, :x)
  end

  private
end
