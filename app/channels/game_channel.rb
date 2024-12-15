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

  def broadcast_world_restart(data)
    ActionCable.server.broadcast(
      "game_channel_#{@world_id}",
      {
        type: 'world_restart',
        world_id: data['world_id']
      }
    )
  end

  def broadcast_treasure_found(data)
    ActionCable.server.broadcast(
      "game_channel_#{@world_id}",
      {
        type: 'treasure_found',
        finder_id: data['finder_id']
      }
    )
  end

  def receive(data)
    case data['action']
    when 'broadcast_movement'
      broadcast_movement(data)
    when 'broadcast_terrain_update'
      broadcast_terrain_update(data)
    when 'broadcast_world_restart'
      broadcast_world_restart(data)
    when 'broadcast_treasure_found'
      broadcast_treasure_found(data)
    end
    false
  end
end 