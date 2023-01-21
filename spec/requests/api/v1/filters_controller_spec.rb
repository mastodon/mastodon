# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::FiltersController do
  let!(:user) { Fabricate(:user) }
  let!(:filter1) { Fabricate(:custom_filter, account: user.account) }
  let!(:keyword1) { Fabricate(:custom_filter_keyword, custom_filter: filter1, keyword: 'test_keyword_1') }
  let!(:keyword2) { Fabricate(:custom_filter_keyword, custom_filter: filter1, keyword: 'test_keyword_2') }
  let!(:filter2) { Fabricate(:custom_filter, account: user.account, expires_at: 2.minutes.from_now) }
  let!(:keyword3) { Fabricate(:custom_filter_keyword, custom_filter: filter2, keyword: 'test_keyword_3') }

  path '/api/v1/filters' do
    get('list filters') do
      description <<~MD
        **View your filters**

        > Prior to Mastodon 3.6, matching filters was done client-side and filters could only contain one phrase to filter against.

        Version history:
        - 2.4.3 - added
        - 3.1.0 - added `account` context to filter in profile views
        - 4.0.0 - deprecated. For compatibility purposes, now returns a V1::Filter representing one FilterKeyword  
          (with the `keyword` being presented in the `phrase` attribute).  
          This method will create a Filter that contains only one FilterKeyword.  
          The `title` of the Filter and the `keyword` of the FilterKeyword will be set equal to the `phrase` provided.
      MD
      deprecated true
      tags 'Api', 'V1', 'Filters'
      operationId 'v1FiltersListFilter'
      rswag_auth_scope %w(read read:filters)

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/V1Filter' }

        include_context 'user token auth' do
          let(:user_token_scopes) { 'read:filters' }
        end

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to have_attributes(size: 3).and(
            match_array(
              [
                include({ id: keyword1.id.to_s }),
                include({ id: keyword2.id.to_s }),
                include({ id: keyword3.id.to_s }),
              ]
            )
          )
        end
      end
    end

    post('create filter') do
      description <<~MD
        **Create a filter**
  
        > Prior to Mastodon 3.6, matching filters was done client-side and filters could only contain one phrase to filter against.

        Version history:
        - 2.4.3 - added
        - 3.1.0 - added `account` context to filter in profile views
        - 4.0.0 - deprecated. For compatibility purposes, now returns a V1::Filter representing one FilterKeyword  
          (with the `keyword` being presented in the `phrase` attribute).  
          This method will create a Filter that contains only one FilterKeyword.  
          The `title` of the Filter and the `keyword` of the FilterKeyword will be set equal to the `phrase` provided.
      MD
      deprecated true
      tags 'Api', 'V1', 'Filters'
      operationId 'v1FiltersCreateFilter'
      rswag_auth_scope %w(write write:filters)
      parameter name: 'payload', in: :body, required: true, schema: {
        allOf: [
          { '$ref' => '#/components/schemas/V1FilterParams' },
          {
            type: :object,
            properties: {
              phrase: {
                type: :string,
                description: 'The text to be filtered.',
              },
            },
          },
        ],
        required: %w(phrase context),
      }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/V1Filter'
        let(:payload) { { phrase: 'xyz-offence', context: %w(public home thread) } }
        include_context 'user token auth' do
          let(:user_token_scopes) { 'write:filters' }
        end
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/filters/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show filter') do
      description <<~MD
        **View a single filter**
  
        > Prior to Mastodon 3.6, matching filters was done client-side and filters could only contain one phrase to filter against.

        Version history:
        - 2.4.3 - added
        - 3.1.0 - added `account` context to filter in profile views
        - 4.0.0 - deprecated. For compatibility purposes, now returns a V1::Filter representing one FilterKeyword  
          (with the `keyword` being presented in the `phrase` attribute).  
          This method will create a Filter that contains only one FilterKeyword.  
          The `title` of the Filter and the `keyword` of the FilterKeyword will be set equal to the `phrase` provided.
      MD
      deprecated true
      tags 'Api', 'V1', 'Filters'
      operationId 'v1FiltersShowFilter'
      rswag_auth_scope %w(read read:filters)

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/V1Filter'
        let(:id) { keyword1.id }

        include_context 'user token auth' do
          let(:user_token_scopes) { 'read:filters' }
        end

        rswag_add_examples!
        run_test!
      end
    end

    patch('update filter') do
      description <<~MD
        **Update a filter**

        > Prior to Mastodon 3.6, matching filters was done client-side and filters could only contain one phrase to filter against.

        Version history:
        - 2.4.3 - added
        - 3.1.0 - added `account` context to filter in profile views
        - 4.0.0 - deprecated. For compatibility purposes, now returns a V1::Filter representing one FilterKeyword  
          (with the `keyword` being presented in the `phrase` attribute).  
          This method will create a Filter that contains only one FilterKeyword.  
          The `title` of the Filter and the `keyword` of the FilterKeyword will be set equal to the `phrase` provided.
      MD
      deprecated true
      tags 'Api', 'V1', 'Filters'
      operationId 'v1FiltersUpdateFilter'
      rswag_auth_scope %w(write write:filters)
      parameter name: 'payload', in: :body, required: true, schema: {
        '$ref' => '#/components/schemas/V1FilterParams',
      }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/V1Filter'
        let(:id) { keyword3.id }
        let(:payload) { { context: %w(public home thread) } }

        include_context 'user token auth' do
          let(:user_token_scopes) { 'write:filters' }
        end

        rswag_add_examples!
        run_test!
      end
    end

    put('update filter') do
      description <<~MD
        **Replace filter parameters in-place**

        > Prior to Mastodon 3.6, matching filters was done client-side and filters could only contain one phrase to filter against.

        Version history:
        - 2.4.3 - added
        - 3.1.0 - added `account` context to filter in profile views
        - 4.0.0 - deprecated. For compatibility purposes, now returns a V1::Filter representing one FilterKeyword  
          (with the `keyword` being presented in the `phrase` attribute).  
          This method will create a Filter that contains only one FilterKeyword.  
          The `title` of the Filter and the `keyword` of the FilterKeyword will be set equal to the `phrase` provided.
      MD
      deprecated true
      tags 'Api', 'V1', 'Filters'
      operationId 'v1FiltersUpdateFilter'
      rswag_auth_scope %w(write write:filters)
      parameter name: 'payload', in: :body, required: true, schema: {
        '$ref' => '#/components/schemas/V1FilterParams',
      }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/V1Filter'
        let(:id) { keyword3.id }
        let(:payload) { { context: %w(public home thread) } }

        include_context 'user token auth' do
          let(:user_token_scopes) { 'write:filters' }
        end

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete filter') do
      description <<~MD
        **Remove a filter**

        > Prior to Mastodon 3.6, matching filters was done client-side and filters could only contain one phrase to filter against.

        Version history:
        - 2.4.3 - added
        - 3.1.0 - added `account` context to filter in profile views
        - 4.0.0 - deprecated. For compatibility purposes, now returns a V1::Filter representing one FilterKeyword  
          (with the `keyword` being presented in the `phrase` attribute).  
          This method will create a Filter that contains only one FilterKeyword.  
          The `title` of the Filter and the `keyword` of the FilterKeyword will be set equal to the `phrase` provided.
      MD
      deprecated true
      tags 'Api', 'V1', 'Filters'
      operationId 'v1FiltersDeleteFilter'
      rswag_auth_scope %w(write write:filters)

      response(200, 'successful') do
        schema type: :object, properties: {}
        let(:id) { keyword1.id }

        include_context 'user token auth' do
          let(:user_token_scopes) { 'write:filters' }
        end

        rswag_add_examples!
        run_test! do
          expect { keyword1.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
