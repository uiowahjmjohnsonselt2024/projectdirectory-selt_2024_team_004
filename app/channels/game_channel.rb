class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_channel_#{params[:world_id]}"
    @world_id = params[:world_id]
  end

  def unsubscribed
    stop_all_streams
  end

  def broadcast_movement(data)
    ActionCable.server.broadcast(
      "game_channel_#{@world_id}", 
      {
        type: 'character_moved',
        character_id: data['character_id'],
        x: data['x'],
        y: data['y']
      }
    )
  end

  def broadcast_terrain_update(data)
    ActionCable.server.broadcast(
      "game_channel_#{@world_id}", 
      {
        type: 'terrain_updated',
        square_id: data['square_id'],
        terrain: data['terrain'],
        state: data['state']
      }
    )
    false
  end

  def receive(data)
    case data['action']
    when 'broadcast_movement'
      broadcast_movement(data)
      false
    when 'broadcast_terrain_update'
      broadcast_terrain_update(data)
      false
    end
  end
end 