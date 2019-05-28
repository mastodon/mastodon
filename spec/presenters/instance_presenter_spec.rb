require 'rails_helper'

describe InstancePresenter do
  let(:instance_presenter) { InstancePresenter.new }

  context do
    around do |example|
      site_description = Setting.site_description
      example.run
      Setting.site_description = site_description
    end

    it "delegates site_description to Setting" do
      Setting.site_description = "Site desc"

      expect(instance_presenter.site_description).to eq "Site desc"
    end
  end

  context do
    around do |example|
      site_extended_description = Setting.site_extended_description
      example.run
      Setting.site_extended_description = site_extended_description
    end

    it "delegates site_extended_description to Setting" do
      Setting.site_extended_description = "Extended desc"

      expect(instance_presenter.site_extended_description).to eq "Extended desc"
    end
  end

  context do
    around do |example|
      open_registrations = Setting.open_registrations
      example.run
      Setting.open_registrations = open_registrations
    end

    it "delegates open_registrations to Setting" do
      Setting.open_registrations = false

      expect(instance_presenter.open_registrations).to eq false
    end
  end

  context do
    around do |example|
      closed_registrations_message = Setting.closed_registrations_message
      example.run
      Setting.closed_registrations_message = closed_registrations_message
    end

    it "delegates closed_registrations_message to Setting" do
      Setting.closed_registrations_message = "Closed message"

      expect(instance_presenter.closed_registrations_message).to eq "Closed message"
    end
  end

  context do
    around do |example|
      site_contact_email = Setting.site_contact_email
      example.run
      Setting.site_contact_email = site_contact_email
    end

    it "delegates contact_email to Setting" do
      Setting.site_contact_email = "admin@example.com"

      expect(instance_presenter.site_contact_email).to eq "admin@example.com"
    end
  end

  describe "contact_account" do
    around do |example|
      site_contact_username = Setting.site_contact_username
      example.run
      Setting.site_contact_username = site_contact_username
    end

    it "returns the account for the site contact username" do
      Setting.site_contact_username = "aaa"
      account = Fabricate(:account, username: "aaa")

      expect(instance_presenter.contact_account).to eq(account)
    end
  end

  describe "user_count" do
    it "returns the number of site users" do
      Rails.cache.write 'user_count', 123

      expect(instance_presenter.user_count).to eq(123)
    end
  end

  describe "status_count" do
    it "returns the number of local statuses" do
      Rails.cache.write 'local_status_count', 234

      expect(instance_presenter.status_count).to eq(234)
    end
  end

  describe "domain_count" do
    it "returns the number of known domains" do
      Rails.cache.write 'distinct_domain_count', 345

      expect(instance_presenter.domain_count).to eq(345)
    end
  end

  describe '#version_number' do
    it 'returns Mastodon::Version' do
      expect(instance_presenter.version_number).to be(Mastodon::Version)
    end
  end

  describe '#source_url' do
    it 'returns "https://github.com/tootsuite/mastodon"' do
      expect(instance_presenter.source_url).to eq('https://github.com/tootsuite/mastodon')
    end
  end

  describe '#thumbnail' do
    it 'returns SiteUpload' do
      thumbnail = Fabricate(:site_upload, var: 'thumbnail')
      expect(instance_presenter.thumbnail).to eq(thumbnail)
    end
  end

  describe '#hero' do
    it 'returns SiteUpload' do
      hero = Fabricate(:site_upload, var: 'hero')
      expect(instance_presenter.hero).to eq(hero)
    end
  end

  describe '#mascot' do
    it 'returns SiteUpload' do
      mascot = Fabricate(:site_upload, var: 'mascot')
      expect(instance_presenter.mascot).to eq(mascot)
    end
  end
end
