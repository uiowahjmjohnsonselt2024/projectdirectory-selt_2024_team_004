class SettingsController < ApplicationController
  before_action :current_user

  def show
    @user = @current_user
    @currencies = OpenExchangeService.fetch_currencies
    session[:return_path] = params[:return_path] || request.referrer
  end

  def update
    if @current_user.update(default_currency: params[:currency])
      flash[:notice] = 'Settings saved successfully!'
      return_path = session[:return_path]
      if return_path.present?
        return_path = "#{return_path}#{return_path.include?('?') ? '&' : '?'}user_id=#{@current_user.id}" unless return_path.include?('user_id=')
      else
        return_path = landing_path(user_id: @current_user.id)
      end
      redirect_to return_path
    else
      Rails.logger.error "Update failed: #{@current_user.errors.full_messages}"
      flash[:alert] = 'Could not save settings.'
      redirect_to settings_path
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
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
