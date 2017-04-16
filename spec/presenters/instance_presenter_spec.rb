require 'rails_helper'

describe InstancePresenter do
  let(:instance_presenter) { InstancePresenter.new }

  it "delegates site_description to Setting" do
    Setting.site_description = "Site desc"

    expect(instance_presenter.site_description).to eq "Site desc"
  end

  it "delegates site_extended_description to Setting" do
    Setting.site_extended_description = "Extended desc"

    expect(instance_presenter.site_extended_description).to eq "Extended desc"
  end

  it "delegates closed_registrations_message to Setting" do
    Setting.closed_registrations_message = "Closed message"

    expect(instance_presenter.closed_registrations_message).to eq "Closed message"
  end

  it "delegates contact_email to Setting" do
    Setting.site_contact_email = "admin@example.com"

    expect(instance_presenter.site_contact_email).to eq "admin@example.com"
  end
  
  context "when Setting.open_registrations is false" do
    it "closes registrations" do
      Setting.open_registrations = false

      expect(instance_presenter.open_registrations).to eq false
    end
  end
  
  context "when Setting.open_registrations is true" do
    before :all do
      Setting.open_registrations = true
    end
      
    it "closes registrations when user_count >= max_users" do
      Setting.max_users = 100
      allow(Rails.cache).to receive(:fetch).and_call_original
      allow(Rails.cache).to receive(:fetch).with("user_count").and_return(100)
      expect(instance_presenter.open_registrations).to eq false
    end
    
    it "opens registrations when user_count < max_users" do
      Setting.max_users = 100
      allow(Rails.cache).to receive(:fetch).and_call_original
      allow(Rails.cache).to receive(:fetch).with("user_count").and_return(99)
      expect(instance_presenter.open_registrations).to eq true
    end
    
    it "opens registrations when max_users is nil" do
      Setting.max_users = nil

      expect(instance_presenter.open_registrations).to eq true
    end
  end

  describe "contact_account" do
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
end
