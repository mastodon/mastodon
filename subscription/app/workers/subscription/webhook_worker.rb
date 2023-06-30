# frozen_string_literal: true

class WebhookWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'default'

  def perform(event_id)
    event = ::Stripe::Event.retrieve(params[:id])
  end
end
