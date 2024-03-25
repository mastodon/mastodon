# frozen_string_literal: true

class ApplicationWorker
  include Sidekiq::Worker

  def perform(*)
    raise NotImplementedError
  end
end
