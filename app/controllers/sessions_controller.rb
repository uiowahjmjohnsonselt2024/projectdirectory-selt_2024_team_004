class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:session_token] = user.session_token
      session[:user_id] = user.id
      @current_user = user
      redirect_to worlds_path(user_id: user.id), notice: 'Logged in successfully!'
    else
      flash.now[:warning] = 'Invalid email or password'
      render 'new'
    end
  end

  def destroy
    session[:session_token] = nil
    redirect_to root_path, notice: 'Logged out successfully!'
  end
end
