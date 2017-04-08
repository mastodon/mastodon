# frozen_string_literal: true

class ApplicationWorker
  def info(message)
    Rails.logger.info("#{self.class.name} - #{message}")
  end
end
