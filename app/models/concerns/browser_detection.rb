# frozen_string_literal: true

module BrowserDetection
  extend ActiveSupport::Concern

  included do
    before_save :assign_user_agent
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

  private

  def assign_user_agent
    self.user_agent ||= ''
  end
end
