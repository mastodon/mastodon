# frozen_string_literal: true

ActionMailer::MailDeliveryJob.class_eval do
  discard_on ActiveJob::DeserializationError
end
