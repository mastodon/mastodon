# frozen_string_literal: true

module StreamingClientHelper
  def streaming_client
    @streaming_client ||= StreamingClient.new
  end
end
