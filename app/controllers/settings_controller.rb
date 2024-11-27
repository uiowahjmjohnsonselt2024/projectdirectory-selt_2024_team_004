class SettingsController < ApplicationController
  before_action :authenticate

  def show
    @user = current_user
    @currencies = OpenExchangeService.fetch_currencies
    @character = prepare_character
  end

  def update
    @user = current_user
    if @user.update(default_currency: params[:currency])
      flash[:notice] = 'Settings saved successfully!'
    else
      flash[:alert] = 'Could not save settings.'
    end
    redirect_to settings_path
  end

  private

  def prepare_character
    user_world = UserWorld.find_by(user_id: @user.id, world_id: params[:world_id])
    if user_world
      OpenStruct.new(
        role: user_world.user_role,
        picture_url: character_picture_url(user_world.user_role),
        name: "Character for #{user_world.user_role}"
      )
    end
  end

  def character_picture_url(role)
    {
      'Captain' => '1_1_1.png',
      'Navigator' => '1_2_2.png',
      'Crew Member' => '1_3_3.png'
    }[role] || '1_1_1.png'
  end

  def require_login
    redirect_to login_path unless current_user
  end

  # Authenticate user using HTTP Digest
  def authenticate
    authenticate_with_http_digest do |email|
      USERS[email] # Fetch password for the email
    end
  end

  def current_user
    @current_user ||= User.find_by(session_token: session[:session_token])
  end

  def user_params
    params.require(:user).permit(:name, :email, :default_currency)
  end
end