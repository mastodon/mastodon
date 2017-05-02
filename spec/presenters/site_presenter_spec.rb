require 'rails_helper'

describe SitePresenter do
  subject { described_class.new }

  it "delegates site_description to Setting" do
    Setting.site_description = "Site desc"

    expect(subject.site_description).to eq "Site desc"
  end

  it "delegates site_extended_description to Setting" do
    Setting.site_extended_description = "Extended desc"

    expect(subject.site_extended_description).to eq "Extended desc"
  end

  it "delegates open_registrations to Setting" do
    Setting.open_registrations = false

    expect(subject.open_registrations).to eq false
  end

  it "delegates closed_registrations_message to Setting" do
    Setting.closed_registrations_message = "Closed message"

    expect(subject.closed_registrations_message).to eq "Closed message"
  end

  it "delegates contact_email to Setting" do
    Setting.site_contact_email = "admin@example.com"

    expect(subject.site_contact_email).to eq "admin@example.com"
  end

  describe "contact_account" do
    it "returns the account for the site contact username" do
      Setting.site_contact_username = "aaa"
      account = Fabricate(:account, username: "aaa")

      expect(subject.contact_account).to eq(account)
    end
  end

  describe "user_count" do
    it "returns the number of site users" do
      cache = double
      allow(Rails).to receive(:cache).and_return(cache)
      allow(cache).to receive(:fetch).with("user_count").and_return(123)

      expect(subject.user_count).to eq(123)
    end
  end

  describe "status_count" do
    it "returns the number of local statuses" do
      cache = double
      allow(Rails).to receive(:cache).and_return(cache)
      allow(cache).to receive(:fetch).with("local_status_count").and_return(234)

      expect(subject.status_count).to eq(234)
    end
  end

  describe "domain_count" do
    it "returns the number of known domains" do
      cache = double
      allow(Rails).to receive(:cache).and_return(cache)
      allow(cache).to receive(:fetch).with("distinct_domain_count").and_return(345)

      expect(subject.domain_count).to eq(345)
    end
  end
end
