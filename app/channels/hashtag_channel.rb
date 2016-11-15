# frozen_string_literal: true

class HashtagChannel < ApplicationCable::Channel
  def subscribed
    tag = params[:tag].downcase

    stream_from "timeline:hashtag:#{tag}", lambda { |encoded_message|
      status, message = hydrate_status(encoded_message)
      next if filter?(status)
      transmit message
    }
  end
end
