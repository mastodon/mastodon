# frozen_string_literal: true

class PushUpdateWorker
  include Sidekiq::Worker

  def perform(account_id, status_id, timeline_id = nil)
    account     = Account.find(account_id)
    status      = Status.find(status_id)
    timeline_id = "timeline:#{account.id}" if timeline_id.nil?

    Redis.current.publish(timeline_id, Oj.dump(ActiveModelSerializers::SerializableResource.new(
      status,
      serializer: Streaming::UpdateSerializer,
      scope: account.user,
      scope_name: :current_user
    ).as_json))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
