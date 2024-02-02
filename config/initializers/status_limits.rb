# frozen_string_literal: true

Rails.application.configure do
  config.x.max_attachments_per_status = 16
  config.x.allow_mixture_attachement_type = true
  config.x.max_status_length = 1000
end
