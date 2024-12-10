# frozen_string_literal: true

class TriggerWebhookWithObjectWorker
  include Sidekiq::Worker

  # Triggers a webhook for a destructive event (e.g. an unfollow),
  # where the object cannot be queried from the database.
  # @param event [String] type of the event
  # @param object [String] event payload serialized with JSON
  def perform(event, object)
    WebhookService.new.call(event, Oj.load(object))
  end
end
