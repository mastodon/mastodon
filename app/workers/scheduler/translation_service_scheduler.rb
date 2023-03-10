# frozen_string_literal: true

class Scheduler::TranslationServiceScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform
    return unless TranslationService.configured?

    Rails.cache.write('translation_service/languages', TranslationService.configured.languages)
  end
end
