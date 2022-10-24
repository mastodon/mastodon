require 'rails_helper'

describe ActivityPub::UpdateRemoteGroupAdminsWorker do
  subject { described_class.new }

  let!(:group)    { Fabricate(:group, domain: 'example.com', uri: 'https://example.com/inbox') }
  let!(:remote1)  { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/actor1', protocol: :activitypub) }
  let!(:remote2)  { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/actor2', protocol: :activitypub) }
  let!(:remote3)  { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/actor3', protocol: :activitypub) }
  let!(:remote4)  { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/actor4', protocol: :activitypub) }
  let!(:remote5)  { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/actor5', protocol: :activitypub) }
  let!(:remote6)  { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/actor6', protocol: :activitypub) }

  before do
    service = double
    allow(ActivityPub::FetchRemoteAccountService).to receive(:new).and_return(service)
    allow(service).to receive(:call).with('https://example.com/actor7') do
      Fabricate(:account, domain: 'example.com', uri: 'https://example.com/actor7', protocol: :activitypub)
    end

    group.memberships.create!(account: remote1, role: :admin)
    group.memberships.create!(account: remote2, role: :admin)
    group.memberships.create!(account: remote3)
    group.memberships.create!(account: remote4)
  end

  let(:new_uris) {
    [remote1.uri, remote3.uri, remote5.uri, 'https://example.com/actor7']
  }

  describe '#perform' do
    it 'updates the memberships as expected' do
      expect(group.memberships.joins(:account).where(role: [:admin, :moderator]).map { |membership| membership.account.uri }).to match_array([remote1.uri, remote2.uri])
      subject.perform(group.id, new_uris)
      expect(group.memberships.joins(:account).where(role: [:admin, :moderator]).map { |membership| membership.account.uri }).to match_array(new_uris)
    end
  end
end
