# frozen_string_literal: true

class PublishScheduledStatusWorker
  include Sidekiq::Worker

  def perform(scheduled_status_id)
    scheduled_status = ScheduledStatus.find(scheduled_status_id)
    scheduled_status.destroy!

    PostStatusService.new.call(
      scheduled_status.account,
      options_with_objects(scheduled_status.params.with_indifferent_access)
    )
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
    true
  end

  def options_with_objects(options)
    options.tap do |options_hash|
      options_hash[:application] = Doorkeeper::Application.find(options_hash.delete(:application_id)) if options[:application_id]
      options_hash[:thread]      = Status.find(options_hash.delete(:in_reply_to_id)) if options_hash[:in_reply_to_id]
    end
  end
end
