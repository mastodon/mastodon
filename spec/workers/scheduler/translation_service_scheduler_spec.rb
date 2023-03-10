# frozen_string_literal: true

require 'rails_helper'

describe Scheduler::TranslationServiceScheduler do
  subject(:scheduler) { described_class.new }

  describe '#perform' do
    before do
      service = instance_double(TranslationService::LibreTranslate, languages: { 'en' => ['de'] })
      allow(TranslationService).to receive(:configured?).and_return(true)
      allow(TranslationService).to receive(:configured).and_return(service)
    end

    it 'populates the languages cache' do
      scheduler.perform
      expect(Rails.cache.fetch('translation_service/languages')).to eq({ 'en' => ['de'] })
    end
  end
end
