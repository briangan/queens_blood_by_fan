
class GamesChannel < ApplicationCable::Channel
  def subscribed
    if params["game_id"].present?
      stream_from "game_#{params["game_id"]}_channel"
    else
      stream_from "games_channel"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
