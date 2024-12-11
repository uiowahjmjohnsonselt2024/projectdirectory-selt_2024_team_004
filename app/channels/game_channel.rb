class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_channel_#{params[:world_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def move(data)
    character = Character.find(data['character_id'])
    character.update(x_coord: data['x'], y_coord: data['y'])
    
    ActionCable.server.broadcast "game_channel_#{params[:world_id]}", {
      character_id: character.id,
      x_coord: data['x'],
      y_coord: data['y'],
      image_code: character.image_code
    }
  end
end 