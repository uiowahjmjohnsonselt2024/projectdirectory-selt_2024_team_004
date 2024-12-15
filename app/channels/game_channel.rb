class GameChannel < ApplicationCable::Channel
  def subscribed
    # Stream from a unique channel for this world
    stream_from "game_channel_#{params[:world_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def broadcast_square_unlock(data)
    ActionCable.server.broadcast(
      "game_channel_#{params[:world_id]}", 
      {
        type: 'square_unlocked',
        square_id: data['square_id'],
        square_code: data['square_code']
      }
    )
  end

  def receive(data)
    # Handle any incoming data from the client
    case data['action']
    when 'move'
      broadcast_movement(data)
    when 'unlock_square'
      broadcast_square_unlock(data)
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