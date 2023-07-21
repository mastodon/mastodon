# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::DirectoriesController do
  render_views

  let(:user)    { Fabricate(:user, confirmed_at: nil) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:follows') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    context 'with no params' do
      before do
        _local_unconfirmed_account = Fabricate(
          :account,
          domain: nil,
          user: Fabricate(:user, confirmed_at: nil, approved: true),
          username: 'local_unconfirmed'
        )

        local_unapproved_account = Fabricate(
          :account,
          domain: nil,
          user: Fabricate(:user, confirmed_at: 10.days.ago),
          username: 'local_unapproved'
        )
        local_unapproved_account.user.update(approved: false)

        _local_undiscoverable_account = Fabricate(
          :account,
          domain: nil,
          user: Fabricate(:user, confirmed_at: 10.days.ago, approved: true),
          discoverable: false,
          username: 'local_undiscoverable'
        )

        excluded_from_timeline_account = Fabricate(
          :account,
          domain: 'host.example',
          discoverable: true,
          username: 'remote_excluded_from_timeline'
        )
        Fabricate(:block, account: user.account, target_account: excluded_from_timeline_account)

        _domain_blocked_account = Fabricate(
          :account,
          domain: 'test.example',
          discoverable: true,
          username: 'remote_domain_blocked'
        )
        Fabricate(:account_domain_block, account: user.account, domain: 'test.example')
      end

      it 'returns only the local discoverable account' do
        local_discoverable_account = Fabricate(
          :account,
          domain: nil,
          user: Fabricate(:user, confirmed_at: 10.days.ago, approved: true),
          discoverable: true,
          username: 'local_discoverable'
        )

        eligible_remote_account = Fabricate(
          :account,
          domain: 'host.example',
          discoverable: true,
          username: 'eligible_remote'
        )

        get :show

        expect(response).to have_http_status(200)
        expect(body_as_json.size).to eq(2)
        expect(body_as_json.first[:id]).to include(eligible_remote_account.id.to_s)
        expect(body_as_json.second[:id]).to include(local_discoverable_account.id.to_s)
      end
    end

    context 'when asking for local accounts only' do
      it 'returns only the local accounts' do
        user = Fabricate(:user, confirmed_at: 10.days.ago, approved: true)
        local_account = Fabricate(:account, domain: nil, user: user)
        remote_account = Fabricate(:account, domain: 'host.example')

        get :show, params: { local: '1' }

        expect(response).to have_http_status(200)
        expect(body_as_json.size).to eq(1)
        expect(body_as_json.first[:id]).to include(local_account.id.to_s)
        expect(response.body).to_not include(remote_account.id.to_s)
      end
    end

    context 'when ordered by active' do
      it 'returns accounts in order of most recent status activity' do
        status_old = Fabricate(:status)
        travel_to 10.seconds.from_now
        status_new = Fabricate(:status)

        get :show, params: { order: 'active' }

        expect(response).to have_http_status(200)
        expect(body_as_json.size).to eq(2)
        expect(body_as_json.first[:id]).to include(status_new.account.id.to_s)
        expect(body_as_json.second[:id]).to include(status_old.account.id.to_s)
      end
    end

    context 'when ordered by new' do
      it 'returns accounts in order of creation' do
        account_old = Fabricate(:account)
        travel_to 10.seconds.from_now
        account_new = Fabricate(:account)

        get :show, params: { order: 'new' }

        expect(response).to have_http_status(200)
        expect(body_as_json.size).to eq(2)
        expect(body_as_json.first[:id]).to include(account_new.id.to_s)
        expect(body_as_json.second[:id]).to include(account_old.id.to_s)
      end
    end
  end
end
