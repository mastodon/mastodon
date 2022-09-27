# frozen_string_literal: true

class ActivityPub::GroupRawDistributionWorker
  include Sidekiq::Worker
  include Payloadable

  sidekiq_options queue: 'push'

  def perform(json, source_group_id, exclude_inboxes = [])
    @group           = Group.find(source_group_id)
    @json            = json
    @exclude_inboxes = exclude_inboxes

    distribute!
  rescue ActiveRecord::RecordNotFound
    true
  end

  protected

  def distribute!
    return if inboxes.empty?

    ActivityPub::GroupDeliveryWorker.push_bulk(inboxes) do |inbox_url|
      [payload, source_group_id, inbox_url, options]
    end
  end

  def payload
    @json
  end

  def source_group_id
    @group.id
  end

  def inboxes
    @inboxes ||= @group.members.inboxes - @exclude_inboxes
  end

  def options
    {}
  end
end
