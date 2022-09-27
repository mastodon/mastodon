require 'rails_helper'

RSpec.describe SuspendGroupService, type: :service do
  describe 'suspending a local account' do
    def match_update_actor_request(req, group)
      json = JSON.parse(req.body)
      actor_id = ActivityPub::TagManager.instance.uri_for(group)
      json['type'] == 'Update' && json['actor'] == actor_id && json['object']['id'] == actor_id && json['object']['suspended']
    end

    let!(:group)         { Fabricate(:group) }
    let!(:local_member)  { Fabricate(:user, current_sign_in_at: 1.hour.ago).account }
    let!(:remote_member) { Fabricate(:account, uri: 'https://alice.com', inbox_url: 'https://alice.com/inbox', protocol: :activitypub) }

    subject { described_class.new.call(group) }

    before do
      stub_request(:post, 'https://alice.com/inbox').to_return(status: 201)
      group.memberships.create!(account: local_member)
      group.memberships.create!(account: remote_member)
    end

    it 'marks group as suspended' do
      expect { subject }.to change { group.suspended? }.from(false).to(true)
    end

    it 'sends an update actor to members' do
      subject
      expect(a_request(:post, remote_member.inbox_url).with { |req| match_update_actor_request(req, group) }).to have_been_made.once
    end
  end
end
