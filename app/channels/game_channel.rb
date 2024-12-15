class GameChannel < ApplicationCable::Channel
  def subscribed
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

  def broadcast_square_update(data)
    ActionCable.server.broadcast(
      "game_channel_#{params[:world_id]}", 
      {
        type: 'square_updated',
        square_id: data['square_id'],
        state: data['state'],
        terrain: data['terrain']
      }
    )
  end

  def receive(data)
    case data['action']
    when 'broadcast_movement'
      broadcast_movement(data)
    when 'broadcast_square_update'
      broadcast_square_update(data)
    end
  end
end 