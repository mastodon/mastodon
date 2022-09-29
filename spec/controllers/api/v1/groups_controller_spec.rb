require 'rails_helper'

RSpec.describe Api::V1::GroupsController, type: :controller do
  render_views

  let!(:user)  { Fabricate(:user) }
  let!(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:locked) { false }
  let(:group)  { Fabricate(:group, locked: locked) }
  let!(:remote_member) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/actor', inbox_url: 'https://example.com/inbox', protocol: :activitypub) }

  before do
    group.memberships.create!(account: remote_member)
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  shared_examples 'forbidden for wrong scope' do |wrong_scope|
    let(:scopes) { wrong_scope }

    it 'returns http forbidden' do
      expect(response).to have_http_status(403)
    end
  end

  describe 'GET #index' do
    let!(:other_group) { Fabricate(:group) }
    let(:scopes) { 'read:groups' }

    before do
      group.memberships.create!(account: user.account, group: group)
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(200)
    end

    it 'returns the expected group' do
      get :index
      expect(body_as_json.map { |item| item[:id] }).to eq [group.id.to_s]
    end
  end

  describe 'GET #show' do
    let!(:other_group) { Fabricate(:group) }
    let(:scopes) { 'read:groups' }

    before do
      group.memberships.create!(account: user.account, group: group)
    end

    it 'returns http success' do
      get :show, params: { id: group.id }
      expect(response).to have_http_status(200)
    end
  end

  describe 'PUT #update' do
    let(:scopes) { 'write:groups' }

    before do
      stub_request(:post, remote_member.inbox_url).to_return(status: 202)
      group.memberships.create!(account: user.account, group: group, role: role)
      put :update, params: { id: group.id, display_name: 'New and improved group name' }
    end

    context 'when group admin' do
      let(:role) { :admin }

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'returns the expected group' do
        expect(body_as_json[:id]).to eq group.id.to_s
        expect(body_as_json[:display_name]).to eq 'New and improved group name'
      end

      it 'updates the group' do
        expect(group.reload.display_name).to eq 'New and improved group name'
      end

      it 'sends an Update to remote group members' do
        expect(a_request(:post, remote_member.inbox_url).with do |req|
          json = Oj.load(req.body)
          json['type'] == 'Update' && json['actor'] == ActivityPub::TagManager.instance.uri_for(group) && json['object']['type'] == 'PublicGroup' # TODO
        end).to have_been_made.once
      end
    end

    context 'when group moderator' do
      let(:role) { :moderator }

      it 'returns http forbidden' do
        expect(response).to have_http_status(403)
      end

      it 'does not update the group' do
        expect(group.reload.display_name).to_not eq 'New and improved group name'
      end

      it 'does not send an Update to remote group members' do
        expect(a_request(:post, remote_member.inbox_url)).to_not have_been_made
      end
    end

    context 'when no group role' do
      let(:role) { :user }

      it 'returns http forbidden' do
        expect(response).to have_http_status(403)
      end

      it 'does not update the group' do
        expect(group.reload.display_name).to_not eq 'New and improved group name'
      end

      it 'does not send an Update to remote group members' do
        expect(a_request(:post, remote_member.inbox_url)).to_not have_been_made
      end
    end
  end

  describe 'POST #create' do
    let(:scopes) { 'write:groups' }

    before do
      user.update!(role: Fabricate(:user_role, permissions: UserRole::FLAGS[:create_groups]))
      post :create, params: { display_name: 'Mastodon development group' }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns a group of which the user is an admin' do
      expect(body_as_json[:id].present?).to be true
      expect(body_as_json[:display_name]).to eq 'Mastodon development group'
      expect(Group.find(body_as_json[:id]).memberships.find_by(account_id: user.account.id).admin_role?).to eq true
    end
  end

  describe 'POST #join' do
    let(:scopes) { 'write:groups' }

    context do
      before do
        stub_request(:post, 'https://example.com/group-inbox').to_return(status: 202)
        stub_request(:post, remote_member.inbox_url).to_return(status: 202)
        post :join, params: { id: group.id }
      end

      context 'with an unlocked local group' do
        let(:locked) { false }

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns JSON with member=true and requested=false' do
          json = body_as_json

          expect(json[:member]).to be true
          expect(json[:requested]).to be false
        end

        it 'creates a group membership' do
          expect(group.memberships.find_by(account_id: user.account.id)).to_not be_nil
        end

        it 'sends an Add activity to remote users' do
          expect(a_request(:post, remote_member.inbox_url).with do |req|
            json = Oj.load(req.body)
            json['type'] == 'Add' && json['object'] == ActivityPub::TagManager.instance.uri_for(user.account) && json['target'] == ActivityPub::TagManager.instance.members_uri_for(group) && json['actor'] == ActivityPub::TagManager.instance.uri_for(group)
          end).to have_been_made.once
        end

        it_behaves_like 'forbidden for wrong scope', 'read:groups'
      end

      context 'with locked local group' do
        let(:locked) { true }

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns JSON with member=false and requested=true' do
          json = body_as_json

          expect(json[:member]).to be false
          expect(json[:requested]).to be true
        end

        it 'does not create a group membership' do
          expect(group.memberships.find_by(account_id: user.account.id)).to be_nil
        end

        it 'creates a group membership request' do
          expect(group.membership_requests.find_by(account_id: user.account.id)).to_not be_nil
        end

        it_behaves_like 'forbidden for wrong scope', 'read:groups'
      end

      context 'with remote locked group' do
        let(:group) { Fabricate(:group, domain: 'example.com', uri: 'https://example.com/group', inbox_url: 'https://example.com/group-inbox', locked: true) }

        before do
          stub_request(:post, group.inbox_url).to_return(status: 202)
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns JSON with member=false and requested=true' do
          json = body_as_json

          expect(json[:member]).to be false
          expect(json[:requested]).to be true
        end

        it 'does not create a group membership' do
          expect(group.memberships.find_by(account_id: user.account.id)).to be_nil
        end

        it 'creates a group membership request' do
          expect(group.membership_requests.find_by(account_id: user.account.id)).to_not be_nil
        end

        it 'sends a Join activity to the remote group' do
          expect(a_request(:post, group.inbox_url).with do |req|
            json = Oj.load(req.body)
            json['type'] == 'Join' && json['object'] == ActivityPub::TagManager.instance.uri_for(group) && json['actor'] == ActivityPub::TagManager.instance.uri_for(user.account)
          end).to have_been_made.once
        end

        it_behaves_like 'forbidden for wrong scope', 'read:groups'
      end

      context 'with remote unlocked group' do
        let(:group) { Fabricate(:group, domain: 'example.com', uri: 'https://example.com/group', inbox_url: 'https://example.com/group-inbox', locked: false) }

        before do
          stub_request(:post, group.inbox_url).to_return(status: 202)
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns JSON with member=true and requested=false' do
          json = body_as_json

          expect(json[:member]).to be true
          expect(json[:requested]).to be false
        end

        it 'does not create a group membership' do
          expect(group.memberships.find_by(account_id: user.account.id)).to be_nil
        end

        it 'creates a group membership request' do
          expect(group.membership_requests.find_by(account_id: user.account.id)).to_not be_nil
        end

        it 'sends a Join activity to the remote group' do
          expect(a_request(:post, group.inbox_url).with do |req|
            json = Oj.load(req.body)
            json['type'] == 'Join' && json['object'] == ActivityPub::TagManager.instance.uri_for(group) && json['actor'] == ActivityPub::TagManager.instance.uri_for(user.account)
          end).to have_been_made.once
        end

        it_behaves_like 'forbidden for wrong scope', 'read:groups'
      end
    end
  end

  describe 'POST #leave' do
    let(:scopes) { 'write:groups' }

    before do
      stub_request(:post, 'https://example.com/group-inbox').to_return(status: 202)
      stub_request(:post, remote_member.inbox_url).to_return(status: 202)
      group.memberships.create!(account: user.account, group: group)
      post :leave, params: { id: group.id }
    end

    context 'with a local group' do
      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'removes the following relation between user and target user' do
        expect(group.memberships.find_by(account_id: user.account.id)).to be_nil
      end

      it 'sends a Remove activity to remote users' do
        expect(a_request(:post, remote_member.inbox_url).with do |req|
          json = Oj.load(req.body)
          json['type'] == 'Remove' && json['object'] == ActivityPub::TagManager.instance.uri_for(user.account) && json['target'] == ActivityPub::TagManager.instance.members_uri_for(group) && json['actor'] == ActivityPub::TagManager.instance.uri_for(group)
        end).to have_been_made.once
      end
    end

    context 'with a remote group' do
      let(:group) { Fabricate(:group, domain: 'example.com', uri: 'https://example.com/group', inbox_url: 'https://example.com/group-inbox', locked: true) }

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'removes the following relation between user and target user' do
        expect(group.memberships.find_by(account_id: user.account.id)).to be_nil
      end

      it 'sends a Leave activity to the remote group' do
        expect(a_request(:post, group.inbox_url).with do |req|
          json = Oj.load(req.body)
          json['type'] == 'Leave' && json['object'] == ActivityPub::TagManager.instance.uri_for(group) && json['actor'] == ActivityPub::TagManager.instance.uri_for(user.account)
        end).to have_been_made.once
      end
    end

    it_behaves_like 'forbidden for wrong scope', 'read:groups'
  end

  describe 'POST #kick' do
    let(:scopes) { 'write:groups' }
    let(:membership) { Fabricate(:group_membership, group: group) }

    context 'when the user is not a group member' do
      it 'returns http forbidden' do
        post :kick, params: { id: group.id, account_ids: [membership.account.id] }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user has no special role within the group' do
      before do
        group.memberships.create!(account: user.account)
      end

      it 'returns http forbidden' do
        post :kick, params: { id: group.id, account_ids: [membership.account.id] }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user is a group admin' do
      before do
        stub_request(:post, remote_member.inbox_url).to_return(status: 202)
        group.memberships.create!(account: user.account, role: :admin)
        post :kick, params: { id: group.id, account_ids: [membership.account.id] }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'deletes the membership' do
        expect(group.memberships.find_by(account: membership.account)).to be_nil
      end

      it 'sends a Remove activity to remote users' do
        expect(a_request(:post, remote_member.inbox_url).with do |req|
          json = Oj.load(req.body)
          json['type'] == 'Remove' && json['object'] == ActivityPub::TagManager.instance.uri_for(membership.account) && json['target'] == ActivityPub::TagManager.instance.members_uri_for(group) && json['actor'] == ActivityPub::TagManager.instance.uri_for(group)
        end).to have_been_made.once
      end
    end
  end

  describe 'POST #promote' do
    let(:scopes) { 'write:groups' }
    let(:membership) { Fabricate(:group_membership, group: group) }

    context 'when the user is not a group member' do
      it 'returns http forbidden' do
        post :promote, params: { id: group.id, account_ids: [membership.account.id], role: 'moderator' }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user has no special role within the group' do
      before do
        group.memberships.create!(account: user.account)
      end

      it 'returns http forbidden' do
        post :promote, params: { id: group.id, account_ids: [membership.account.id], role: 'moderator' }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user is a group admin' do
      before do
        stub_request(:post, remote_member.inbox_url).to_return(status: 202)
        group.memberships.create!(account: user.account, role: :admin)
        post :promote, params: { id: group.id, account_ids: [membership.account.id], role: 'moderator' }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'changes the role' do
        expect(group.memberships.find_by(account: membership.account).role).to eq 'moderator'
      end

      it 'sends an Update to remote group members' do
        expect(a_request(:post, remote_member.inbox_url).with do |req|
          json = Oj.load(req.body)
          json['type'] == 'Update' && json['actor'] == ActivityPub::TagManager.instance.uri_for(group) && json['object']['type'] == 'PublicGroup' # TODO
        end).to have_been_made.once
      end
    end

    context 'when the user is a group moderator' do
      before do
        stub_request(:post, remote_member.inbox_url).to_return(status: 202)
        group.memberships.create!(account: user.account, role: :moderator)
        post :promote, params: { id: group.id, account_ids: [membership.account.id], role: 'moderator' }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'changes the role' do
        expect(group.memberships.find_by(account: membership.account).role).to eq 'moderator'
      end

      it 'sends an Update to remote group members' do
        expect(a_request(:post, remote_member.inbox_url).with do |req|
          json = Oj.load(req.body)
          json['type'] == 'Update' && json['actor'] == ActivityPub::TagManager.instance.uri_for(group) && json['object']['type'] == 'PublicGroup' # TODO
        end).to have_been_made.once
      end
    end

    context 'when the user is a group moderator trying to promote someone admin' do
      before do
        group.memberships.create!(account: user.account, role: :moderator)
      end

      it 'returns http forbidden' do
        post :promote, params: { id: group.id, account_ids: [membership.account.id], role: 'admin' }

        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'POST #demote' do
    let(:scopes) { 'write:groups' }
    let(:membership) { Fabricate(:group_membership, group: group) }

    context 'when the user is not a group member' do
      it 'returns http forbidden' do
        post :demote, params: { id: group.id, account_ids: [membership.account.id], role: 'user' }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user has no special role within the group' do
      before do
        group.memberships.create!(account: user.account)
        post :demote, params: { id: group.id, account_ids: [membership.account.id], role: 'user' }
      end

      it 'returns http forbidden' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the user is a group admin' do
      before do
        stub_request(:post, remote_member.inbox_url).to_return(status: 202)
        membership.update!(role: :moderator)
        group.memberships.create!(account: user.account, role: :admin)
        post :demote, params: { id: group.id, account_ids: [membership.account.id], role: 'user' }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'changes the role' do
        expect(group.memberships.find_by(account: membership.account).role).to eq 'user'
      end

      it 'sends an Update to remote group members' do
        expect(a_request(:post, remote_member.inbox_url).with do |req|
          json = Oj.load(req.body)
          json['type'] == 'Update' && json['actor'] == ActivityPub::TagManager.instance.uri_for(group) && json['object']['type'] == 'PublicGroup' # TODO
        end).to have_been_made.once
      end
    end

    context 'when the user is a group admin trying to demote another admin' do
      before do
        stub_request(:post, remote_member.inbox_url).to_return(status: 202)
        membership.update!(role: :admin)
        group.memberships.create!(account: user.account, role: :admin)
        post :demote, params: { id: group.id, account_ids: [membership.account.id], role: 'user' }
      end

      it 'returns http forbidden' do
        expect(response).to have_http_status(403)
      end

      it 'does not change the role' do
        expect(group.memberships.find_by(account: membership.account).role).to eq 'admin'
      end
    end

    context 'when the user is a group moderator trying to demote another moderator' do
      before do
        stub_request(:post, remote_member.inbox_url).to_return(status: 202)
        membership.update!(role: :moderator)
        group.memberships.create!(account: user.account, role: :moderator)
        post :demote, params: { id: group.id, account_ids: [membership.account.id], role: 'user' }
      end

      it 'returns http forbidden' do
        expect(response).to have_http_status(403)
      end

      it 'does not change the role' do
        expect(group.memberships.find_by(account: membership.account).role).to eq 'moderator'
      end
    end

    context 'when the user is a group administrator trying to "demote" a user to a higher role' do
      before do
        stub_request(:post, remote_member.inbox_url).to_return(status: 202)
        membership.update!(role: :moderator)
        group.memberships.create!(account: user.account, role: :admin)
        post :demote, params: { id: group.id, account_ids: [membership.account.id], role: 'admin' }
      end

      it 'returns returns http unprocessable entity' do
        expect(response).to have_http_status(422)
      end

      it 'does not change the role' do
        expect(group.memberships.find_by(account: membership.account).role).to eq 'moderator'
      end
    end
  end
end
