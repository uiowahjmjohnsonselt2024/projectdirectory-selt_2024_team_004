class InvitationsController < ApplicationController
  def create
    receiver = User.find_by(email: params[:email])
    world_id = params[:world_id]

    if !receiver
      flash.now['alert-danger'] = "User with that email not found."
    elsif receiver == current_user
      flash.now['alert-danger'] = "You cannot invite yourself."
    elsif Invitation.exists?(receiver_id: receiver&.id, world_id: world_id, status: ['pending', 'accepted'])
      flash.now['alert-danger'] = "You have already invited that player."
    else
      invitation = Invitation.new(
        sender_id: current_user.id,
        receiver_id: receiver.id,
        world_id: world_id,
        status: 'pending'
      )
      
      if invitation.save
        flash.now['alert-success'] = "Invitation sent to #{receiver.email}!"
      else
        flash.now['alert-danger'] = "Failed to send invitation."
      end
    end

    respond_to do |format|
      format.html { redirect_to worlds_path }
      format.js { render partial: 'shared/flash', locals: { flash: flash } }
    end
  end
end 