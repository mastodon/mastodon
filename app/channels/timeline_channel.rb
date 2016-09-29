class TimelineChannel < ApplicationCable::Channel
  def subscribed
    stream_from "timeline:#{current_user.account_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
