# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::AccountsController, type: :request do
  path '/api/v1/accounts/{id}/follow' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('follow account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsFollowAccount'
      description 'Follow the given account. Can also be used to update whether to show reblogs or enable notifications.'
      rswag_auth_scope %w(follow write write:follows)
      parameter name: :payload, in: :body, required: false, schema: {
        type: :object,
        properties: {
          reblogs: { type: :boolean, description: "Receive this account's reblogs in home timeline? Defaults to true." },
          notify: { type: :boolean, description: 'Receive notifications when this account posts a status? Defaults to false.' },
        },
      }

      include_context 'user token auth' do
        let(:user_token_scopes) { 'follow write:follows' }
      end
      let!(:account) { Fabricate(:account) }

      response(200, 'follow not following') do
        schema '$ref' => '#/components/schemas/Relationship'
        let(:id) { account.id }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to include(
            { id: account.id.to_s, following: true }.stringify_keys
          )
        end
      end

      response(200, 'follow already following') do
        schema '$ref' => '#/components/schemas/Relationship'
        let(:id) { account.id }
        before { user.account.follow!(account) }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to include(
            { id: account.id.to_s, following: true }.stringify_keys
          )
        end
      end
    end
  end

  path '/api/v1/accounts/{id}/unfollow' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('unfollow account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsUnfollowAccount'
      rswag_auth_scope %w(follow write write:follows)

      include_context 'user token auth' do
        let(:user_token_scopes) { 'follow write:follows' }
      end
      let!(:account) { Fabricate(:account) }

      response(200, 'unfollow following') do
        schema '$ref' => '#/components/schemas/Relationship'
        let(:id) { account.id }
        before { user.account.follow!(account) }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to include(
            { id: account.id.to_s, following: false }.stringify_keys
          )
        end
      end

      response(200, 'unfollow not following') do
        schema '$ref' => '#/components/schemas/Relationship'
        let(:id) { account.id }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to include(
            { id: account.id.to_s, following: false }.stringify_keys
          )
        end
      end
    end
  end

  path '/api/v1/accounts/{id}/remove_from_followers' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('remove_from_followers account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsRemoveFromFollowersAccount'
      rswag_auth_scope %w(follow write write:follows)

      include_context 'user token auth' do
        let(:user_token_scopes) { 'follow write:follows' }
      end
      let!(:account) { Fabricate(:account) }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Relationship'
        let(:id) { account.id }
        before do
          account.follow!(user.account)
        end

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to include(
            { id: account.id.to_s, following: false, followed_by: false }.stringify_keys
          )
        end
      end
    end
  end

  path '/api/v1/accounts/{id}/block' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('block account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsBlockAccount'
      rswag_auth_scope %w(follow write write:blocks)

      include_context 'user token auth' do
        let(:user_token_scopes) { 'follow write:blocks' }
      end
      let!(:account) { Fabricate(:account) }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Relationship'
        let(:id) { account.id }
        before do
          account.follow!(user.account)
        end

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to include(
            { id: account.id.to_s, following: false, followed_by: false, blocking: true }.stringify_keys
          )
        end
      end
    end
  end

  path '/api/v1/accounts/{id}/unblock' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('unblock account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsUnblockAccount'
      rswag_auth_scope %w(follow write write:blocks)

      include_context 'user token auth' do
        let(:user_token_scopes) { 'follow write:blocks' }
      end
      let!(:account) { Fabricate(:account) }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Relationship'
        let(:id) { account.id }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/accounts/{id}/mute' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('mute account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsMuteAccount'
      rswag_auth_scope %w(follow write write:mutes)

      include_context 'user token auth' do
        let(:user_token_scopes) { 'follow write:mutes' }
      end
      let!(:account) { Fabricate(:account) }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Relationship'
        let(:id) { account.id }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/accounts/{id}/unmute' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('unmute account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsUnmuteAccount'
      rswag_auth_scope %w(follow write write:mutes)

      include_context 'user token auth' do
        let(:user_token_scopes) { 'follow write:mutes' }
      end
      let!(:account) { Fabricate(:account) }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Relationship'
        let(:id) { account.id }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/accounts' do
    post('create account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsCreateAccount'
      description 'Creates a user and account records. Returns an account access token for the app that initiated the request. The app should save this token for later, and should wait for the user to confirm their account by clicking a link in their email inbox.'
      rswag_auth_scope %w(write write:accounts)
      parameter name: :payload, in: :body, required: :true, schema: {
        type: :object,
        properties: {
          username: {
            type: :string,
            description: 'The desired username for the account',
          },
          email: {
            type: :string,
            description: 'The email address to be used for login',
          },
          password: {
            type: :string,
            description: 'The password to be used for login',
          },
          agreement: {
            type: :string,
            description: 'Whether the user agrees to the local rules, terms, and policies. These should be presented to the user in order to allow them to consent before setting this parameter to TRUE.',
          },
          locale: {
            type: :string, pattern: '[a-z]{2}',
            description: 'The language of the confirmation email that will be sent'
          },
          reason: {
            type: :string,
            description: 'Text that will be reviewed by moderators if registrations require manual approval.',
          },
        },
        required: %w(username email password agreement),
      }

      let(:user)   { Fabricate(:user) }
      let(:scopes) { '' }
      let!(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

      let(:app) { Fabricate(:application) }
      let(:user_token) do
        tok = Doorkeeper::AccessToken.new(application: app, scopes: 'read write write:accounts', use_refresh_token: false)
        tok.save
        tok.reload
      end
      let!(:authorization) do
        binding.pry
        "Bearer #{user_token.token}"
      end

      response(200, 'successful') do
        let(:payload) do
          {
            username: 'tester',
            email: 'tester@anywhere.com',
            password: '12345678',
            agreement: 'true',
            locale: 'en',
            reaon: 'something reasonable',
          }
        end
        # TODO: Fix not working spec
        # rswag_add_examples!
        # run_test!
      end
    end
  end

  path '/api/v1/accounts/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsShowAccount'
      rswag_auth_scope %w(read read:accounts)

      include_context 'user token auth' do
        let(:user_token_scopes) { 'read:accounts' }
      end
      let!(:account) { Fabricate(:account) }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Relationship'
        let(:id) { account.id }

        rswag_add_examples!
        run_test!
      end
    end
  end
end
