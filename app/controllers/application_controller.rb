class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: :json_request?
  before_action :authenticate_user!

  helper_method :current_user

  protected

  def json_request?
    request.format.json?
  end

  private
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    unless current_user
      flash[:alert] = "You must be logged in to access this page"
      redirect_to login_path
    end
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