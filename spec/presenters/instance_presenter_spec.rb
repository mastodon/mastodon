# frozen_string_literal: true

require 'rails_helper'

describe InstancePresenter do
  let(:instance_presenter) { described_class.new }

  describe '#description' do
    around do |example|
      site_description = Setting.site_short_description
      example.run
      Setting.site_short_description = site_description
    end

    it 'delegates site_description to Setting' do
      Setting.site_short_description = 'Site desc'
      expect(instance_presenter.description).to eq 'Site desc'
    end
  end

  describe '#extended_description' do
    around do |example|
      site_extended_description = Setting.site_extended_description
      example.run
      Setting.site_extended_description = site_extended_description
    end

    it 'delegates site_extended_description to Setting' do
      Setting.site_extended_description = 'Extended desc'
      expect(instance_presenter.extended_description).to eq 'Extended desc'
    end
  end

  describe '#email' do
    around do |example|
      site_contact_email = Setting.site_contact_email
      example.run
      Setting.site_contact_email = site_contact_email
    end

    it 'delegates contact_email to Setting' do
      Setting.site_contact_email = 'admin@example.com'
      expect(instance_presenter.contact.email).to eq 'admin@example.com'
    end
  end

  describe '#account' do
    around do |example|
      site_contact_username = Setting.site_contact_username
      example.run
      Setting.site_contact_username = site_contact_username
    end

    it 'returns the account for the site contact username' do
      Setting.site_contact_username = 'aaa'
      account = Fabricate(:account, username: 'aaa')
      expect(instance_presenter.contact.account).to eq(account)
    end
  end

  describe '#translation' do
    context 'when no translation service is configured' do
      it 'returns empty language matrix' do
        expect(instance_presenter.translation_languages).to eq({})
      end
    end

    context 'when a translation service is configured but cache is empty' do
      before do
        allow(TranslationService).to receive(:configured?).and_return(true)
      end

      it 'returns empty language matrix' do
        expect(instance_presenter.translation_languages).to eq({})
      end
    end

    context 'when a translation service is configured and cache is populated' do
      before do
        service = instance_double(TranslationService::DeepL, languages: { nil => %w(en de), 'en' => ['de'] })
        allow(TranslationService).to receive(:configured?).and_return(true)
        allow(TranslationService).to receive(:configured).and_return(service)
        Scheduler::TranslationServiceScheduler.new.perform
      end

      it 'returns language matrix' do
        expect(instance_presenter.translation_languages).to eq({ 'und' => %w(en de), 'en' => ['de'] })
      end
    end
  end

  describe '#user_count' do
    it 'returns the number of site users' do
      Rails.cache.write 'user_count', 123

      expect(instance_presenter.user_count).to eq(123)
    end
  end

  describe '#status_count' do
    it 'returns the number of local statuses' do
      Rails.cache.write 'local_status_count', 234

      expect(instance_presenter.status_count).to eq(234)
    end
  end

  describe '#domain_count' do
    it 'returns the number of known domains' do
      Rails.cache.write 'distinct_domain_count', 345

      expect(instance_presenter.domain_count).to eq(345)
    end
  end

  describe '#version' do
    it 'returns string' do
      expect(instance_presenter.version).to be_a String
    end
  end

  describe '#source_url' do
    it 'returns "https://github.com/mastodon/mastodon"' do
      expect(instance_presenter.source_url).to eq('https://github.com/mastodon/mastodon')
    end
  end

  describe '#thumbnail' do
    it 'returns SiteUpload' do
      thumbnail = Fabricate(:site_upload, var: 'thumbnail')
      expect(instance_presenter.thumbnail).to eq(thumbnail)
    end
  end

  describe '#mascot' do
    it 'returns SiteUpload' do
      mascot = Fabricate(:site_upload, var: 'mascot')
      expect(instance_presenter.mascot).to eq(mascot)
    end
  end
end
