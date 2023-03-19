# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::Admin::AccountsController do
  render_views

  let(:role)   { UserRole.find_by(name: 'Moderator') }
  let(:user)   { Fabricate(:user, role: role) }
  let(:scopes) { 'admin:read admin:write' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:account) { Fabricate(:account) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    let!(:remote_account) { Fabricate(:account, domain: 'example.org') }
    let!(:suspended_account)    { Fabricate(:account, suspended: true) }
    let!(:suspended_remote)     { Fabricate(:account, domain: 'foo.bar', suspended: true) }
    let!(:disabled_account)     { Fabricate(:user, disabled: true).account }
    let!(:pending_account)      { Fabricate(:user, approved: false).account }
    let!(:admin_account)        { user.account }

    let(:params) { {} }

    before do
      pending_account.user.update(approved: false)
      get :index, params: params
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    context 'when status active and origin local and permissions staff' do
      let(:params) { { status: 'active', origin: 'local', permissions: 'staff' } }

      it 'produces results with the admin_account' do
        expect_results_of([admin_account])
      end
    end

    context 'when by_domain is present and origin remote' do
      let(:params) { { by_domain: 'example.org', origin: 'remote' } }

      it 'produces results with the remote_account' do
        expect_results_of([remote_account])
      end
    end

    context 'when status suspended' do
      let(:params) { { status: 'suspended' } }

      it 'produces results with the suspended accounts' do
        expect_results_of([suspended_remote, suspended_account])
      end
    end

    context 'when status disabled' do
      let(:params) { { status: 'disabled' } }

      it 'produces results with the disabled_account' do
        expect_results_of([disabled_account])
      end
    end

    context 'when status pending' do
      let(:params) { { status: 'pending' } }

      it 'produces results with the pending_account' do
        expect_results_of([pending_account])
      end
    end

    context 'with limit param' do
      let(:params) { { limit: 1 } }

      it 'sets the correct pagination headers' do
        expect(response.headers['Link'].find_link(%w(rel next)).href).to eq api_v2_admin_accounts_url(limit: 1, max_id: admin_account.id)
      end
    end

    private

    def expect_results_of(records)
      expect(response).to have_http_status(200)
      expect(body_as_json.map { |a| a[:id].to_i }).to eq(records.map(&:id))
    end
  end
end
