class GameChannel < ApplicationCable::Channel
  def subscribed
    channel = "game_channel_#{params[:world_id]}"
    Rails.logger.info "Subscribing to channel: #{channel}"
    stream_from channel
  end

  def unsubscribed
    Rails.logger.info "Unsubscribed from channel"
  end

  def broadcast_movement(data)
    Rails.logger.info "Broadcasting movement: #{data.inspect}"
    channel = "game_channel_#{params[:world_id]}"
    
    ActionCable.server.broadcast(
      channel, 
      {
        type: 'character_moved',
        character_id: data['character_id'],
        x: data['x'],
        y: data['y']
      }
    )
    Rails.logger.info "Movement broadcast completed"
  end

  def receive(data)
    Rails.logger.info "Received data in GameChannel: #{data.inspect}"
    case data['action']
    when 'broadcast_movement'
      broadcast_movement(data)
    end
  end
end 