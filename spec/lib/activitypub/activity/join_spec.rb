require 'rails_helper'

RSpec.describe ActivityPub::Activity::Join do
  let(:sender) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/actor', inbox_url: 'https://example.com/inbox', protocol: :activitypub) }
  let(:group)  { Fabricate(:group) }
  let!(:remote_member) { Fabricate(:account, domain: 'example.com', uri: 'https//example.com/other', inbox_url: 'https://example.com/other-inbox', protocol: :activitypub) }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'https://example.com/activities/1',
      type: 'Join',
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
      context 'unlocked group' do
        before do
          stub_request(:post, sender.inbox_url).to_return(status: 202)
          stub_request(:post, remote_member.inbox_url).to_return(status: 202)
          subject.perform
        end

        it 'creates a group membership' do
          expect(group.memberships.find_by(account: sender).uri).to eq json[:id]
        end

        it 'does not create a membership request' do
          expect(group.membership_requests.where(account: sender).exists?).to be false
        end

        it 'sends an Accept activity' do
          expect(a_request(:post, sender.inbox_url).with do |req|
            accept_json = Oj.load(req.body)
            accept_json['type'] == 'Accept' && accept_json['object']['type'] == 'Join' && accept_json['object']['id'] == json[:id]
          end).to have_been_made.once
        end

        it 'sends an Add activity to the other member' do
          expect(a_request(:post, remote_member.inbox_url).with do |req|
            add_json = Oj.load(req.body)
            add_json['type'] == 'Add' && add_json['object'] == ActivityPub::TagManager.instance.uri_for(sender) && add_json['target'] == ActivityPub::TagManager.instance.members_uri_for(group) && add_json['actor'] == ActivityPub::TagManager.instance.uri_for(group)
          end).to have_been_made.once
        end
      end

      context 'silenced account trying to join an unlocked group' do
        before do
          sender.touch(:silenced_at)
          subject.perform
        end

        it 'creates a membership request' do
          expect(group.membership_requests.find_by(account_id: sender.id).uri).to eq json[:id]
        end

        it 'does not create a membership' do
          expect(group.memberships.where(account: sender).exists?).to be false
        end
      end

      context 'locked group' do
        before do
          group.update(locked: true)
          subject.perform
        end

        it 'creates a membership request' do
          expect(group.membership_requests.find_by(account_id: sender.id).uri).to eq json[:id]
        end

        it 'does not create a membership' do
          expect(group.memberships.where(account: sender).exists?).to be false
        end
      end

      context 'when account is blocked' do
        before do
          stub_request(:post, sender.inbox_url).to_return(status: 202)
          group.account_blocks.create!(account: sender)
          subject.perform
        end

        it 'does not create a membership request' do
          expect(group.membership_requests.where(account: sender).exists?).to be false
        end

        it 'does not create a membership' do
          expect(group.memberships.where(account: sender).exists?).to be false
        end

        it 'sends a Reject activity' do
          expect(a_request(:post, sender.inbox_url).with do |req|
            reject_json = Oj.load(req.body)
            reject_json['type'] == 'Reject' && reject_json['object']['type'] == 'Join' && reject_json['object']['id'] == json[:id]
          end).to have_been_made.once
        end
      end

      context 'when group is suspended' do
        before do
          stub_request(:post, sender.inbox_url).to_return(status: 202)
          group.suspend!
          subject.perform
        end

        it 'does not create a membership request' do
          expect(group.membership_requests.where(account: sender).exists?).to be false
        end

        it 'does not create a membership' do
          expect(group.memberships.where(account: sender).exists?).to be false
        end

        it 'sends a Reject activity' do
          expect(a_request(:post, sender.inbox_url).with do |req|
            reject_json = Oj.load(req.body)
            reject_json['type'] == 'Reject' && reject_json['object']['type'] == 'Join' && reject_json['object']['id'] == json[:id]
          end).to have_been_made.once
        end
      end
    end

    context 'when a membership already exists' do
      before do
        stub_request(:post, sender.inbox_url).to_return(status: 202)
        group.memberships.create!(account: sender, uri: 'bar')
      end

      context 'unlocked group' do
        before do
          subject.perform
        end

        it 'correctly sets the new URI' do
          expect(group.memberships.find_by(account: sender).uri).to eq json[:id]
        end

        it 'does not create a membership request' do
          expect(group.membership_requests.where(account: sender).exists?).to be false
        end

        it 'sends an Accept activity' do
          expect(a_request(:post, sender.inbox_url).with do |req|
            accept_json = Oj.load(req.body)
            accept_json['type'] == 'Accept' && accept_json['object']['type'] == 'Join' && accept_json['object']['id'] == json[:id]
          end).to have_been_made.once
        end
      end

      context 'silenced account member of an unlocked group' do
        before do
          sender.touch(:silenced_at)
          subject.perform
        end

        it 'correctly sets the new URI' do
          expect(group.memberships.find_by(account: sender).uri).to eq json[:id]
        end

        it 'does not create a membership request' do
          expect(group.membership_requests.where(account: sender).exists?).to be false
        end

        it 'sends an Accept activity' do
          expect(a_request(:post, sender.inbox_url).with do |req|
            accept_json = Oj.load(req.body)
            accept_json['type'] == 'Accept' && accept_json['object']['type'] == 'Join' && accept_json['object']['id'] == json[:id]
          end).to have_been_made.once
        end
      end

      context 'locked account' do
        before do
          group.update(locked: true)
          subject.perform
        end

        it 'correctly sets the new URI' do
          expect(group.memberships.find_by(account: sender).uri).to eq json[:id]
        end

        it 'does not create a membership request' do
          expect(group.membership_requests.where(account: sender).exists?).to be false
        end

        it 'sends an Accept activity' do
          expect(a_request(:post, sender.inbox_url).with do |req|
            accept_json = Oj.load(req.body)
            accept_json['type'] == 'Accept' && accept_json['object']['type'] == 'Join' && accept_json['object']['id'] == json[:id]
          end).to have_been_made.once
        end
      end
    end

    context 'when a membership request already exists' do
      before do
        group.membership_requests.create!(account: sender, uri: 'bar')
      end

      context 'silenced account trying to be a member of a locked group' do
        before do
          sender.touch(:silenced_at)
          subject.perform
        end

        it 'does not create a membership' do
          expect(group.memberships.where(account: sender).exists?).to be false
        end

        it 'correctly sets the new URI' do
          expect(group.membership_requests.find_by(account_id: sender.id).uri).to eq json[:id]
        end
      end

      context 'locked group' do
        before do
          group.update(locked: true)
          subject.perform
        end

        it 'does not create a membership' do
          expect(group.memberships.where(account: sender).exists?).to be false
        end

        it 'correctly sets the new URI' do
          expect(group.membership_requests.find_by(account_id: sender.id).uri).to eq json[:id]
        end
      end
    end
  end
end
