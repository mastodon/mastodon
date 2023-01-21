# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::ListsController do
  let(:local_account) { Fabricate(:user).account }
  let(:remote_account) { Fabricate(:account, domain: 'else.where') }

  path '/api/v1/lists' do
    get('list lists') do
      tags 'Api', 'V1', 'Lists'
      operationId 'v1ListsListList'
      rswag_auth_scope %w(read read:lists)

      include_context 'user token auth' do
        let(:user_token_scopes) { 'read:lists' }
      end
      let!(:list1) { List.create(title: 'list1', account: user.account) }

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/List' }
        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to have_attributes(size: 1).and(
            match_array(
              [
                include({ title: 'list1' }),
              ]
            )
          )
        end
      end
    end

    post('create list') do
      tags 'Api', 'V1', 'Lists'
      operationId 'v1ListsCreateList'
      rswag_auth_scope %w(write write:lists)
      parameter name: :payload, in: :body, required: true, schema: {
        type: :object,
        properties: {
          title: { type: :string, description: 'The title of the list to be created.' },
          replies_policy: {
            description: 'One of followed, list, or none. Defaults to list.',
            type: :string,
            enum: %w(followed list none),
            default: 'list',
          },
        },
        required: %w(title),
      }

      include_context 'user token auth' do
        let(:user_token_scopes) { 'write:lists' }
      end

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/List'
        let!(:payload) { { title: 'test_title1', replies_policy: 'none' } }
        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to include({ title: 'test_title1', replies_policy: 'none' })
        end
      end
    end
  end

  path '/api/v1/lists/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show list') do
      tags 'Api', 'V1', 'Lists'
      operationId 'v1ListsShowList'
      rswag_auth_scope %w(read read:lists)

      include_context 'user token auth' do
        let(:user_token_scopes) { 'read:lists' }
      end
      let!(:list1) { List.create(title: 'list1', account: user.account) }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/List'
        let(:id) { list1.id }

        rswag_add_examples!
        run_test!
      end
    end

    patch('update list') do
      tags 'Api', 'V1', 'Lists'
      operationId 'v1ListsUpdateList'
      rswag_auth_scope %w(write write:lists)
      parameter name: :payload, in: :body, required: true, schema: {
        type: :object,
        properties: {
          title: { type: :string, description: 'The title of the list to be created.' },
          replies_policy: {
            description: 'One of followed, list, or none. Defaults to list.',
            type: :string,
            enum: %w(followed list none),
            default: 'list',
          },
        },
        required: %w(title),
      }

      include_context 'user token auth' do
        let(:user_token_scopes) { 'write:lists' }
      end
      let!(:list1) { List.create(title: 'list1', account: user.account) }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/List'
        let(:id) { list1.id }
        let!(:payload) { { title: 'test_title1', replies_policy: 'none' } }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to include({ title: 'test_title1', replies_policy: 'none' })
        end
      end
    end

    put('update list') do
      tags 'Api', 'V1', 'Lists'
      operationId 'v1ListsUpdateList'
      rswag_auth_scope %w(write write:lists)
      parameter name: :payload, in: :body, required: true, schema: {
        type: :object,
        properties: {
          title: { type: :string, description: 'The title of the list to be created.' },
          replies_policy: {
            description: 'One of followed, list, or none. Defaults to list.',
            type: :string,
            enum: %w(followed list none),
            default: 'list',
          },
        },
        required: %w(title),
      }

      include_context 'user token auth' do
        let(:user_token_scopes) { 'write:lists' }
      end
      let!(:list1) { List.create(title: 'list1', account: user.account) }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/List'
        let(:id) { list1.id }
        let!(:payload) { { title: 'test_title1', replies_policy: 'none' } }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to include({ title: 'test_title1', replies_policy: 'none' })
        end
      end
    end

    delete('delete list') do
      tags 'Api', 'V1', 'Lists'
      operationId 'v1ListsDeleteList'
      rswag_auth_scope %w(write write:lists)

      include_context 'user token auth' do
        let(:user_token_scopes) { 'write:lists' }
      end
      let!(:list1) { List.create(title: 'list1', account: user.account) }

      response(200, 'successful') do
        schema type: :object, properties: {}
        let(:id) { list1.id }

        rswag_add_examples!
        run_test!
      end
    end
  end
end
