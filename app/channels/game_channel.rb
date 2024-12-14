class GameChannel < ApplicationCable::Channel
  def subscribed
    # Stream from a unique channel for this world
    stream_from "game_channel_#{params[:world_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    # Handle any incoming data from the client
    case data['action']
    when 'move'
      broadcast_movement(data)
    end
  end

  private

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
end 