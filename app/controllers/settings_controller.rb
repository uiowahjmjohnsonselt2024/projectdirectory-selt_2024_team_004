class SettingsController < ApplicationController
  before_action :current_user

  def show
    @user ||= User.find_by id: params[:user_id] || User.find_by(id: session[:user_id])
    @world ||= World.find_by id: params[:world_id] || World.find_by(id: session[:world_id])
    @character ||= Character.find_by(user_id: @user.id, world_id: @world.id) || Character.find_by(character_id: session[:character_id])
    @currencies = OpenExchangeService.fetch_currencies
    session[:return_path] = params[:return_path] || request.referrer
    @character_image = @character&.image_code
    role = @character_image[4] # Code has form "gender_preload_role.png"
    @role = case role.to_i
            when 1 then 'Captain'
            when 2 then 'Doctor'
            when 3 then 'Navigator'
            else 'Invalid role'
            end
  end

  def update
    if @current_user.update(default_currency: params[:currency])
      flash[:notice] = 'Settings saved successfully!'
      return_path = session[:return_path]
      if return_path.present?
        unless return_path.include?('user_id=')
          return_path = "#{return_path}#{return_path.include?('?') ? '&' : '?'}user_id=#{@current_user.id}"
        end
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

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
