class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :recovery, :code, :recovery_code, :verify]

  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to worlds_path
    else
      flash.now[:alert] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = 'You have been logged out'
    redirect_to login_path
  end

  def recovery
    render :recovery
  end

  def recovery_code
    @user = User.find_by(email: params[:email])

    if @user.present?
      # Generate a random recovery code (you can customize this logic)
      @recovery_code = SecureRandom.hex(4) # Generates an 8-character code

      # Send the recovery email
      UserMailer.recovery_email(params[:email], @recovery_code).deliver_now

      flash[:notice] = "Recovery code sent to #{params[:email]}"
      redirect_to code_path(email: params[:email], code: @recovery_code)
    else
      flash.now[:alert] = 'An account does not exist under that email'
      render :recovery
    end
  end


  def code
    @user_email = params[:email]  # The email passed via URL
    @recovery_code = params[:code]  # The recovery code passed via URL

    render :code
  end

  def verify
    email = @user_email
    recovery_code = params[:code]

    # Check if the entered code matches the one stored in the URL
    if params[:code] == recovery_code && params[:password] == params[:password_confirm]
      user = User.find_by(email: email)

      if user.present?
        # Update the password
        if user.update(password: params[:password])
          # Log the user in after successful password reset
          session[:user_id] = user.id

          flash[:notice] = 'Password successfully reset.'
          redirect_to login_path
        else
          flash.now[:alert] = 'There was an error updating your password. Please try again.'
          render :code
        end
      else
        flash.now[:alert] = 'User not found'
        render :code
      end
    else
      flash.now[:alert] = 'Invalid recovery code or passwords do not match.'
      render :code
    end
  end
end
