class ApplicationController < ActionController::Base
  protect_from_forgery
  protected

  def current_user?(id)
    @current_user.id.to_s == id
  end

  def set_current_user
    @current_user ||= User.find_by_session_token(session[:session_token])
    redirect_to login_path unless @current_user
  end

  def destroy
    session[:session_token] = nil
    @current_user = nil
    flash[:notice] = 'You have been logged out'
    redirect_to login_path
  end
end