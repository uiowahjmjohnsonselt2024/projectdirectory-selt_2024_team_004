class SquaresController < ApplicationController
  def landing
    store
    @world_id = params[:world_id]

    unless @world_id
      flash[:alert] = "No world selected"
      redirect_to worlds_path and return
    end

    @squares = Square.where(world_id: @world_id).order(:y, :x)
  end

  private

  def store
    @user = current_user
    @currency = @user.default_currency || 'USD'
    @prices = StoreService.fetch_prices(@user)
    puts "User: #{@user}"
    puts "Currency: #{@currency}"
    puts "Prices: #{@prices}"
  end

  def current_user
    @current_user ||= User.find_by id: params[:user_id]
  end
end
