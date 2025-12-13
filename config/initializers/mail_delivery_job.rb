# frozen_string_literal: true

ActionMailer::MailDeliveryJob.class_eval do
  discard_on ActiveJob::DeserializationError do |job, error|
    raise error unless error.cause.is_a?(ActiveRecord::RecordNotFound)
  end
end
