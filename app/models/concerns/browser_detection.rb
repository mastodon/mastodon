# frozen_string_literal: true

module BrowserDetection
  extend ActiveSupport::Concern

  included do
    before_save :assign_user_agent
  end

  delegate :mobile?,
           :tablet?,
           to: :detection,
           prefix: :browser

  def browser
    detection.id
  end

  def platform
    detection.platform.id
  end

  private

  def detection
    @detection ||= Browser.new(user_agent)
  end

  def assign_user_agent
    self.user_agent ||= ''
  end
end
