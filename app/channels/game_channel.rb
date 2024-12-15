class GameChannel < ApplicationCable::Channel
  def subscribed
    # Stream from a unique channel for this world
    stream_from "game_channel_#{params[:world_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def broadcast_movement(data)
    ActionCable.server.broadcast(
      "game_channel_#{params[:world_id]}", 
      {
        type: 'character_moved',
        character_id: data['character_id'],
        x: data['x'],
        y: data['y']
      }
    )
  end

  def receive(data)
    case data['action']
    when 'broadcast_movement'
      broadcast_movement(data)
    end
  end
end 