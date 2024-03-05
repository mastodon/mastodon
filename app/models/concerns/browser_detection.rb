# frozen_string_literal: true

module BrowserDetection
  extend ActiveSupport::Concern

  included do
    normalizes :user_agent, with: ->(value) { value || '' }
  end

  def detection
    @detection ||= Browser.new(user_agent)
  end

  def browser
    detection.id
  end

  def platform
    detection.platform.id
  end
end
