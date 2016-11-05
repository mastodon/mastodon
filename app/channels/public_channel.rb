class PublicChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'timeline:public', lambda { |encoded_message|
      status, message = hydrate_status(encoded_message)
      next if filter?(status)
      transmit message
    }
  end
end
