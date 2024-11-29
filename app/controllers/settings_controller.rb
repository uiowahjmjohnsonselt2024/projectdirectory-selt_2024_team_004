class SettingsController < ApplicationController
  before_action :current_user

  def show
    @user = @current_user
    @currencies = OpenExchangeService.fetch_currencies
    session[:return_path] = params[:return_path] if params[:return_path]
    puts @user
    puts @currencies
  end

  def update
    previous_session_token = @current_user.session_token # Save the current session token

    if @current_user.update(default_currency: params[:currency])
      @current_user.update_column(:session_token, previous_session_token)
      @prices = StoreService.fetch_prices(current_user)
      flash[:notice] = 'Settings saved successfully!'
    else
      Rails.logger.error "Update failed: #{current_user.errors.full_messages}"
      flash[:alert] = 'Could not save settings.'
    end
  end

  private

  def character_picture_url(role)
    {
      'Captain' => '1_1_1.png',
      'Navigator' => '1_2_2.png',
      'Crew Member' => '1_3_3.png'
    }[role] || '1_1_1.png'
  end

  def current_user
    puts session
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
