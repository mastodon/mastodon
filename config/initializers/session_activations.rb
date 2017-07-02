# frozen_string_literal: true

Rails.application.configure do
  config.x.max_session_activations = ENV['MAX_SESSION_ACTIVATIONS'] || 10
end
