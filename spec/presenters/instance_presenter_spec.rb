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
    context 'with the GITHUB_REPOSITORY env variable set' do
      around do |example|
        ClimateControl.modify GITHUB_REPOSITORY: 'other/repo' do
          example.run
        end
      end

      it 'uses the env variable to build a repo URL' do
        expect(instance_presenter.source_url).to eq('https://github.com/other/repo')
      end
    end

    context 'without the GITHUB_REPOSITORY env variable set' do
      around do |example|
        ClimateControl.modify GITHUB_REPOSITORY: nil do
          example.run
        end
      end

      it 'defaults to the core glitch-soc repo URL' do
        expect(instance_presenter.source_url).to eq('https://github.com/glitch-soc/mastodon')
      end
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
