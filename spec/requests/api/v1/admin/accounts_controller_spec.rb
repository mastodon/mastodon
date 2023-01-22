# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::AccountsController do
  path '/api/v1/admin/accounts/{id}/enable' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('Enable a currently disabled account') do
      description 'Re-enable a local account whose login is currently disabled.'
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsEnableAccount'
      rswag_auth_scope %w(admin:write admin:write:accounts)

      include_context 'admin token auth'
      let(:account) { Fabricate(:account, disabled: true) }

      response(200, 'Account was enabled, or was already enabled.') do
        schema '$ref' => '#/components/schemas/Admin::Account'
        let(:id) { account.id }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to include(
            { id: account.id.to_s, disabled: false }.stringify_keys
          )
        end
      end
    end
  end

  path '/api/v1/admin/accounts/{id}/unsensitive' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('Unmark an account as sensitive') do
      description "Stops marking an account's posts as sensitive, if it was previously flagged as sensitive."
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsUnsensitiveAccount'
      rswag_auth_scope %w(admin:write admin:write:accounts)

      include_context 'admin token auth'
      let(:account_user) { Fabricate(:user) }
      let(:account) { Fabricate(:account, user: account_user, sensitive: true) }

      response(200, 'The account is no longer marked as sensitive, or was already not marked as sensitive.') do
        schema '$ref' => '#/components/schemas/Admin::Account'
        let(:id) { account.id }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to include(
            { id: account.id.to_s, sensitized: false }.stringify_keys
          )
        end
      end
    end
  end

  path '/api/v1/admin/accounts/{id}/unsilence' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('Unsilence an account') do
      description 'Unsilence an account if it is currently silenced.'
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsUnsilenceAccount'
      rswag_auth_scope %w(admin:write admin:write:accounts)

      include_context 'admin token auth'
      let(:account) { Fabricate(:account, silenced: true) }

      response(200, 'Account was unsilenced, or was already not silenced') do
        schema '$ref' => '#/components/schemas/Admin::Account'
        let(:id) { account.id }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to include(
            { id: account.id.to_s, silenced: false }.stringify_keys
          )
        end
      end
    end
  end

  path '/api/v1/admin/accounts/{id}/unsuspend' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('Unsuspend an account') do
      description 'Unsuspend a currently suspended account.'
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsUnsuspendAccount'
      rswag_auth_scope %w(admin:write admin:write:accounts)

      include_context 'admin token auth'
      let(:account) { Fabricate(:account, suspended: true) }

      before { account.suspend! }

      response(200, 'Account successfully unsuspended') do
        schema '$ref' => '#/components/schemas/Admin::Account'
        let(:id) { account.id }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to include(
            { id: account.id.to_s, suspended: false }.stringify_keys
          )
        end
      end
    end
  end

  path '/api/v1/admin/accounts/{id}/approve' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('Approve a pending account') do
      description 'Approve the given local account if it is currently pending approval.'
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsApproveAccount'
      rswag_auth_scope %w(admin:write admin:write:accounts)

      include_context 'admin token auth'
      let(:account) { Fabricate(:account, unapproved: true) }

      before do
        account.user.update(approved: false)
      end

      response(200, 'The account is now approved') do
        schema '$ref' => '#/components/schemas/Admin::Account'
        let(:id) { account.id }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to include(
            { id: account.id.to_s, approved: true }.stringify_keys
          )
        end
      end
    end
  end

  path '/api/v1/admin/accounts/{id}/reject' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('Reject a pending account') do
      description 'Reject the given local account if it is currently pending approval.'
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsRejectAccount'
      rswag_auth_scope %w(admin:write admin:write:accounts)

      include_context 'admin token auth'

      response(200, 'successful') do
        schema type: :object, properties: {}
        let(:account) { Fabricate(:account) }
        let(:id) { account.id }
        before do
          account.user.update(approved: false)
        end

        rswag_add_examples!
        run_test! do
          expect(Account.exists?(id: account.id)).to be(false)
        end
      end

      response(403, 'Authorized user is missing a permission, or invalid or missing ' \
                    'Authorization header, or the account is not currently pending.') do
        let(:account) { Fabricate(:account, unapproved: true) }
        let(:id) { account.id }

        rswag_add_examples!
        run_test! do
          expect(Account.exists?(id: account.id)).to be(true)
        end
      end
    end
  end

  path '/api/v1/admin/accounts' do
    get('list accounts') do
      description 'View all accounts, optionally matching certain criteria for filtering, ' \
                  'up to 100 at a time. Pagination may be done with the HTTP Link header ' \
                  'in the response. See Paginating through API responses for more information.'
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsListAccount'
      rswag_auth_scope %w(admin:read admin:read:accounts)

      include_context 'admin token auth'
      let!(:account) { Fabricate(:account) }

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Admin::Account' }
        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to have_attributes(size: 2).and(
            match_array(
              [
                include({ id: admin.account.id.to_s }),
                include({ id: account.id.to_s }),
              ]
            )
          )
        end
      end
    end
  end

  path '/api/v1/admin/accounts/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('View a specific account') do
      description 'View admin-level information about the given account.'
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsShowAccount'
      rswag_auth_scope %w(admin:read admin:read:accounts)

      include_context 'admin token auth'
      let(:account) { Fabricate(:account) }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Admin::Account'
        let(:id) { account.id }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to include(
            { id: account.id.to_s }
          )
        end
      end
    end

    delete('Delete an account') do
      description 'Permanently delete data for a suspended account.'
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsDeleteAccount'
      rswag_auth_scope %w(admin:write admin:write:accounts)

      include_context 'admin token auth'
      let(:suspended_account) { Fabricate(:account, suspended: true) }

      response(200, 'successful') do
        schema type: :object, properties: {}
        let(:id) { suspended_account.id }

        before do
          AccountDeletionRequest.create!(account: suspended_account)
        end

        rswag_add_examples!
        run_test!
      end

      response(403, 'Authorized user is missing a permission, or invalid or missing Authorization ' \
                    'header, or account was already deleted.') do
        let(:account) { Fabricate(:account) }
        let(:id) { suspended_account.id }

        rswag_add_examples!
        run_test!
      end
    end
  end
end
