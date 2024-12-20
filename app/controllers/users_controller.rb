class UsersController < ApplicationController
  before_action :set_current_user, :only=>['show', 'edit', 'update', 'delete']

  def new
    @user = User.new
  end

  def create
    Rails.logger.debug "Parameters received: #{params.inspect}"

    @user = User.new(user_params)
    if @user.save
      flash[:notice] = "Successfully created account!"
      redirect_to login_path
    else
      flash.now[:alert] = "Error: #{@user.errors.full_messages.join(', ')}"
      render :new
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end


