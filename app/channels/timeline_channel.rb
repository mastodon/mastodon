# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class TimelineChannel < ApplicationCable::Channel
  def subscribed
    stream_from "timeline:#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
