require 'rails_helper'

RSpec.describe ActivityPub::Activity::Leave do
  let(:sender) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/actor', inbox_url: 'https://example.com/inbox', protocol: :activitypub) }
  let(:group)  { Fabricate(:group) }
  let!(:remote_member) { Fabricate(:account, domain: 'example.com', uri: 'https//example.com/other', inbox_url: 'https://example.com/other-inbox', protocol: :activitypub) }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'https://example.com/activities/1',
      type: 'Leave',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: ActivityPub::TagManager.instance.uri_for(group),
    }.with_indifferent_access
  end

  before do
    group.memberships.create!(account: remote_member)
  end

  describe '#perform' do
    subject { described_class.new(json, sender, delivered_to_group_id: group.id) }

    context 'with no prior membership' do
      it 'does not change anything to the memberships' do
        expect { subject.perform }.to_not change { group.memberships.pluck(:id, :account_id) }
      end
    end

    context 'when previously a member of the group' do
      before do
        stub_request(:post, sender.inbox_url).to_return(status: 202)
        stub_request(:post, remote_member.inbox_url).to_return(status: 202)
        group.memberships.create!(account: sender)
        subject.perform
      end

      it 'removes the membership' do
        expect(group.members.where(id: sender.id).exists?).to be false
      end

      it 'sends a Remove activity to the other member' do
        expect(a_request(:post, remote_member.inbox_url).with do |req|
          remove_json = Oj.load(req.body)
          remove_json['type'] == 'Remove' && remove_json['object'] == ActivityPub::TagManager.instance.uri_for(sender) && remove_json['target'] == ActivityPub::TagManager.instance.members_uri_for(group) && remove_json['actor'] == ActivityPub::TagManager.instance.uri_for(group)
        end).to have_been_made.once
      end
    end
  end
end
