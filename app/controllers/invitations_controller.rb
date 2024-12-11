class InvitationsController < ApplicationController
  def create
    receiver = User.find_by(email: params[:email])
    world_id = params[:world_id]

    if !receiver
      flash.clear
      flash.now['alert-danger'] = "User with that email not found."
    elsif receiver == current_user
      flash.clear
      flash.now['alert-danger'] = "You cannot invite yourself."
    elsif Invitation.exists?(receiver_id: receiver&.id, world_id: world_id, status: ['pending', 'accepted'])
      flash.clear
      flash.now['alert-danger'] = "You have already invited that player."
    else
      invitation = Invitation.new(
        sender_id: current_user.id,
        receiver_id: receiver.id,
        world_id: world_id,
        status: 'pending'
      )
      
      if invitation.save
        flash.clear
        flash.now['alert-success'] = "Invitation sent to #{receiver.email}!"
      else
        flash.clear
        flash.now['alert-danger'] = "Failed to send invitation."
      end
    end

    respond_to do |format|
      format.html { redirect_to worlds_path }
      format.js { render partial: 'shared/flash', locals: { flash: flash } }
    end
  end

  def accept
    invitation = Invitation.find(params[:id])
    
    if invitation.receiver == current_user
      ActiveRecord::Base.transaction do
        invitation.update!(status: 'accepted')
        # Create UserWorld association with default role 'player'
        UserWorld.create!(
          user: current_user,
          world: invitation.world,
          user_role: 'player',
          owner: false
        )
      end
      flash[:success] = "Invitation accepted! Please create your character."
      redirect_to join_world_form_path(user_world_id: UserWorld.last.id)
    else
      flash[:danger] = "You are not authorized to accept this invitation."
      redirect_to worlds_path
    end
  rescue => e
    flash[:danger] = "Failed to accept invitation: #{e.message}"
    redirect_to worlds_path
  end

  def decline
    invitation = Invitation.find(params[:id])
    
    if invitation.receiver == current_user
      invitation.update(status: 'declined')
      flash[:success] = "Invitation declined."
    else
      flash[:danger] = "You are not authorized to decline this invitation."
    end

    redirect_to worlds_path
  end
end 