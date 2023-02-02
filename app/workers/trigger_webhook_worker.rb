# frozen_string_literal: true

class TriggerWebhookWorker
  include Sidekiq::Worker

  def perform(event, class_name, id)
    object = class_name.constantize.find(id)
    WebhookService.new.call(event, object)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
