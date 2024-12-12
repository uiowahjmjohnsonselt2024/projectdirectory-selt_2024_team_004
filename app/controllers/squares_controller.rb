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
    @game_result = true

    respond_to do |format|
      format.json { render json: { success: true, message: "10 shards deducted successfully.", game_result: @game_result } }
    end
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
