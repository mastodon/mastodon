require 'rails_helper'

RSpec.describe Api::V1::Admin::GroupsController, type: :controller do
  render_views

  let(:role)   { UserRole.find_by(name: 'Moderator') }
  let(:user)   { Fabricate(:user, role: role) }
  let(:scopes) { 'admin:read admin:write' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:group)  { Fabricate(:group, display_name: 'Test group') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  shared_examples 'forbidden for wrong scope' do |wrong_scope|
    let(:scopes) { wrong_scope }

    it 'returns http forbidden' do
      expect(response).to have_http_status(403)
    end
  end

  shared_examples 'forbidden for wrong role' do |wrong_role|
    let(:role) { UserRole.find_by(name: wrong_role) }

    it 'returns http forbidden' do
      expect(response).to have_http_status(403)
    end
  end

  describe 'GET #index' do
    let!(:remote_group)       { Fabricate(:group, domain: 'example.org') }
    let!(:other_remote_group) { Fabricate(:group, domain: 'foo.bar') }
    let!(:suspended_group)    { Fabricate(:group, suspended: true) }
    let!(:suspended_remote)   { Fabricate(:group, domain: 'foo.bar', suspended: true) }
    let!(:account)            { Fabricate(:account, id: 1312) }

    let(:params) { {} }

    before do
      remote_group.memberships.create!(account: account)
      suspended_remote.memberships.create!(account: account)

      get :index, params: params
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    [
      [{ by_domain: 'example.org' }, [:remote_group]],
      [{ status: 'suspended' }, [:suspended_group, :suspended_remote]],
      [{ by_member: '1312' }, [:remote_group, :suspended_remote]],
    ].each do |params, expected_results|
      context "when called with #{params.inspect}" do
        let(:params) { params }

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it "returns the correct accounts (#{expected_results.inspect})" do
          json = body_as_json

          expect(json.map { |a| a[:id].to_i }).to match_array(expected_results.map { |symbol| send(symbol).id })
        end
      end
    end
  end

  describe 'GET #show' do
    before do
      get :show, params: { id: group.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #suspend' do
    before do
      post :suspend, params: { id: group.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'suspends group' do
      expect(group.reload.suspended?).to be true
    end
  end

  describe 'POST #unsuspend' do
    before do
      group.suspend!
      post :unsuspend, params: { id: group.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'unsuspends group' do
      expect(group.reload.suspended?).to be false
    end
  end

  describe 'DELETE #destroy' do
    let(:role) { UserRole.find_by(name: 'Admin') }
    let(:service_double) { double }

    before do
      group.suspend!
      allow(service_double).to receive(:call)
      allow(DeleteGroupService).to receive(:new).and_return(service_double)
      delete :destroy, params: { id: group.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', 'Moderator'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'calls DeleteGroupService' do
      expect(service_double).to have_received(:call).with(group, anything).once
    end
  end
end
