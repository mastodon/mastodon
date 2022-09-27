require 'rails_helper'

describe Api::V1::Groups::StatusesController do
  render_views

  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'write:groups' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:group)   { Fabricate(:group, domain: nil) }
  let(:membership) { Fabricate(:group_membership, group: group) }
  let(:status)  { Fabricate(:status, group: group, visibility: :group, account: membership.account, text: 'hello world') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'DELETE #destroy' do
    context 'when the user is not a group member' do
      it 'returns http forbidden' do
        delete :destroy, params: { group_id: group.id, id: status.id }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user has no special role within the group' do
      before do
        group.memberships.create!(account: user.account)
      end

      it 'returns http forbidden' do
        delete :destroy, params: { group_id: group.id, id: status.id }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user is a group admin' do
      let(:remote_member) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/actor', inbox_url: 'https://example.com/inbox', protocol: :activitypub) }

      before do
        stub_request(:post, remote_member.inbox_url).to_return(status: 202)
        group.memberships.create!(account: remote_member)
        group.memberships.create!(account: user.account, role: :admin)
        delete :destroy, params: { group_id: group.id, id: status.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'marks the status as revoked' do
        expect(status.reload.revoked_approval?).to be true
      end

      it 'sends a Remove activity to group members' do
        expect(a_request(:post, remote_member.inbox_url).with do |req|
          remove_json = Oj.load(req.body)
          remove_json['type'] == 'Remove' && remove_json['object'] == ActivityPub::TagManager.instance.uri_for(status) && remove_json['target'] == ActivityPub::TagManager.instance.wall_uri_for(group)
        end).to have_been_made.once
      end
    end
  end
end
