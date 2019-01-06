ActionMailer::DeliveryJob.class_eval do
  discard_on ActiveJob::DeserializationError
end
