# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Directories API' do
  include_context 'with API authentication', oauth_scopes: 'read:follows'

  let(:user)    { Fabricate(:user, confirmed_at: nil) }

  describe 'GET /api/v1/directories' do
    context 'with no params' do
      before do
        local_unconfirmed_account = Fabricate(
          :account,
          domain: nil,
          user: Fabricate(:user, confirmed_at: nil, approved: true),
          username: 'local_unconfirmed'
        )
        local_unconfirmed_account.create_account_stat!

        local_unapproved_account = Fabricate(
          :account,
          domain: nil,
          user: Fabricate(:user, confirmed_at: 10.days.ago),
          username: 'local_unapproved'
        )
        local_unapproved_account.create_account_stat!
        local_unapproved_account.user.update(approved: false)

        local_undiscoverable_account = Fabricate(
          :account,
          domain: nil,
          user: Fabricate(:user, confirmed_at: 10.days.ago, approved: true),
          discoverable: false,
          username: 'local_undiscoverable'
        )
        local_undiscoverable_account.create_account_stat!

        excluded_from_timeline_account = Fabricate(
          :account,
          domain: 'host.example',
          discoverable: true,
          username: 'remote_excluded_from_timeline'
        )
        excluded_from_timeline_account.create_account_stat!
        Fabricate(:block, account: user.account, target_account: excluded_from_timeline_account)

        domain_blocked_account = Fabricate(
          :account,
          domain: 'test.example',
          discoverable: true,
          username: 'remote_domain_blocked'
        )
        domain_blocked_account.create_account_stat!
        Fabricate(:account_domain_block, account: user.account, domain: 'test.example')

        local_discoverable_account.create_account_stat!
        eligible_remote_account.create_account_stat!
      end

      let(:local_discoverable_account) do
        Fabricate(
          :account,
          domain: nil,
          user: Fabricate(:user, confirmed_at: 10.days.ago, approved: true),
          discoverable: true,
          username: 'local_discoverable'
        )
      end

      let(:eligible_remote_account) do
        Fabricate(
          :account,
          domain: 'host.example',
          discoverable: true,
          username: 'eligible_remote'
        )
      end

      it 'returns the local discoverable account and the remote discoverable account' do
        get '/api/v1/directory', headers: headers

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to contain_exactly(
            hash_including(id: eligible_remote_account.id.to_s),
            hash_including(id: local_discoverable_account.id.to_s)
          )
      end
    end

    context 'when asking for local accounts only' do
      let(:user) { Fabricate(:user, confirmed_at: 10.days.ago, approved: true) }
      let(:local_account) { Fabricate(:account, domain: nil, user: user) }
      let(:remote_account) { Fabricate(:account, domain: 'host.example') }

      before do
        local_account.create_account_stat!
        remote_account.create_account_stat!
      end

      it 'returns only the local accounts' do
        get '/api/v1/directory', headers: headers, params: { local: '1' }

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to contain_exactly(
            hash_including(id: local_account.id.to_s)
          )
          .and not_include(remote_account.id.to_s)
      end
    end

    context 'when ordered by active' do
      it 'returns accounts in order of most recent status activity' do
        old_stat = Fabricate(:account_stat, last_status_at: 1.day.ago)
        new_stat = Fabricate(:account_stat, last_status_at: 1.minute.ago)

        get '/api/v1/directory', headers: headers, params: { order: 'active' }

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to contain_exactly(
            hash_including(id: new_stat.account_id.to_s),
            hash_including(id: old_stat.account_id.to_s)
          )
      end
    end

    context 'when ordered by new' do
      it 'returns accounts in order of creation' do
        account_old = Fabricate(:account_stat).account
        travel_to 10.seconds.from_now
        account_new = Fabricate(:account_stat).account

        get '/api/v1/directory', headers: headers, params: { order: 'new' }

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to contain_exactly(
            hash_including(id: account_new.id.to_s),
            hash_including(id: account_old.id.to_s)
          )
      end
    end
  end
end
