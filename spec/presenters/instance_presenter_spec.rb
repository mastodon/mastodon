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
      cache = double
      allow(Rails).to receive(:cache).and_return(cache)
      allow(cache).to receive(:fetch).with("user_count").and_return(123)

      expect(instance_presenter.user_count).to eq(123)
    end
  end

  describe "status_count" do
    it "returns the number of local statuses" do
      cache = double
      allow(Rails).to receive(:cache).and_return(cache)
      allow(cache).to receive(:fetch).with("local_status_count").and_return(234)

      expect(instance_presenter.status_count).to eq(234)
    end
  end

  describe "domain_count" do
    it "returns the number of known domains" do
      cache = double
      allow(Rails).to receive(:cache).and_return(cache)
      allow(cache).to receive(:fetch).with("distinct_domain_count").and_return(345)

      expect(instance_presenter.domain_count).to eq(345)
    end
  end

  describe "active_user_count_30d" do
    it "returns the number of users which logged in the last 30 days" do
      cache = double
      allow(Rails).to receive(:cache).and_return(cache)
      allow(cache).to receive(:fetch).with("active_user_count_30d").and_return(456)

      expect(instance_presenter.domain_count).to eq(456)
    end
  end

  describe "active_user_count_14d" do
    it "returns the number of users which logged in the last 14 days" do
      cache = double
      allow(Rails).to receive(:cache).and_return(cache)
      allow(cache).to receive(:fetch).with("active_user_count_14d").and_return(567)

      expect(instance_presenter.domain_count).to eq(567)
    end
  end

  describe "active_user_count_7d" do
    it "returns the number of users which logged in the last 7 days" do
      cache = double
      allow(Rails).to receive(:cache).and_return(cache)
      allow(cache).to receive(:fetch).with("active_user_count_7d").and_return(678)

      expect(instance_presenter.domain_count).to eq(678)
    end
  end

  describe "active_user_count_1d" do
    it "returns the number of users which logged in the last day" do
      cache = double
      allow(Rails).to receive(:cache).and_return(cache)
      allow(cache).to receive(:fetch).with("active_user_count_1d").and_return(789)

      expect(instance_presenter.domain_count).to eq(789)
    end
  end

  describe "active_user_count_1h" do
    it "returns the number of users which logged in the last hour" do
      cache = double
      allow(Rails).to receive(:cache).and_return(cache)
      allow(cache).to receive(:fetch).with("active_user_count_1h").and_return(1123)

      expect(instance_presenter.domain_count).to eq(1123)
    end
  end

  describe "first_user_created_at" do
    it "returns the date the first user of the instance has been created" do
      cache = double
      allow(Rails).to receive(:cache).and_return(cache)
      allow(cache).to receive(:fetch).with("first_user_created_at").and_return(Date.parse('01-01-2000 01:01:01'))

      expect(instance_presenter.domain_count).to eq(Date.parse('01-01-2000 01:01:01'))
    end
  end
end
