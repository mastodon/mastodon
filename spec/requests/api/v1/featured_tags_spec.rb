# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::FeaturedTagsController do
  let!(:tag1) { Fabricate(:tag) }
  let!(:tag2) { Fabricate(:tag) }
  let!(:tag3) { Fabricate(:tag) }

  path '/api/v1/featured_tags' do
    get('list featured_tags') do
      description 'List all hashtags featured on your profile.'
      tags 'Api', 'V1', 'FeaturedTags'
      operationId 'v1FeaturedtagsListFeaturedTag'
      rswag_auth_scope ['read', 'read:accounts']

      include_context 'user token auth' do
        let(:user_token_scopes) { 'read:accounts' }
      end
      let!(:featured1) { Fabricate(:featured_tag, account: user.account, tag: tag1, name: "#{tag1.name}_featured") }
      let!(:featured2) { Fabricate(:featured_tag, account: user.account, tag: tag2, name: "#{tag2.name}_featured") }

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/FeaturedTag' }
        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to have_attributes(size: 2).and(
            match_array(
              [
                include({ id: featured1.id.to_s }),
                include({ id: featured2.id.to_s }),
              ]
            )
          )
        end
      end

      response(401, 'Unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        include_context 'user token auth' do
          let(:user_token_scopes) { 'read:accounts' }
          let(:authorization) { 'Bearer xyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyz' }
        end
        rswag_add_examples!
        run_test!
      end

      response(403, 'Outside token scope') do
        schema '$ref' => '#/components/schemas/Error'
        include_context 'user token auth' do
          let(:user_token_scopes) { 'read:bookmarks' }
        end
        rswag_add_examples!
        run_test!
      end
    end

    post('create featured_tag') do
      tags 'Api', 'V1', 'FeaturedTags'
      operationId 'v1FeaturedtagsCreateFeaturedTag'
      rswag_auth_scope %w(write write:accounts)
      parameter name: :payload, in: :body, required: true, schema: {
        type: :object,
        properties: {
          name: { type: :string },
        },
        required: %w(name),
      }

      include_context 'user token auth' do
        let(:user_token_scopes) { 'write:accounts' }
      end

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/FeaturedTag'
        let!(:payload) { { name: tag1.name } }
        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(FeaturedTag).to have_attributes(count: 1)
          expect(body).to include({ name: tag1.name, statuses_count: '0', id: FeaturedTag.first.id.to_s })
        end
      end

      response(401, 'Unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        let!(:payload) { { name: tag1.name } }
        include_context 'user token auth' do
          let(:user_token_scopes) { 'write:accounts' }
          let(:authorization) { 'Bearer xyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyz' }
        end
        rswag_add_examples!
        run_test!
      end

      response(403, 'Outside token scope') do
        schema '$ref' => '#/components/schemas/Error'
        let!(:payload) { { name: tag1.name } }
        include_context 'user token auth' do
          let(:user_token_scopes) { 'read:bookmarks' }
        end
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/featured_tags/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    delete('delete featured_tag') do
      tags 'Api', 'V1', 'FeaturedTags'
      operationId 'v1FeaturedtagsDeleteFeaturedTag'
      rswag_auth_scope %w(write write:accounts)

      response(200, 'successful') do
        schema type: :object, properties: {}
        include_context 'user token auth' do
          let(:user_token_scopes) { 'write:accounts' }
        end
        let!(:featured1) { Fabricate(:featured_tag, account: user.account, tag: tag1, name: "#{tag1.name}_featured") }
        let!(:featured2) { Fabricate(:featured_tag, account: user.account, tag: tag2, name: "#{tag2.name}_featured") }
        let(:id) { featured1.id }
        rswag_add_examples!
        run_test! do
          expect { featured1.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect(FeaturedTag).to have_attributes(count: 1)
        end
      end

      response(401, 'Unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        include_context 'user token auth' do
          let(:user_token_scopes) { 'write:accounts' }
          let(:authorization) { 'Bearer xyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyz' }
        end
        let!(:featured1) { Fabricate(:featured_tag, account: user.account, tag: tag1, name: "#{tag1.name}_featured") }
        let!(:featured2) { Fabricate(:featured_tag, account: user.account, tag: tag2, name: "#{tag2.name}_featured") }
        let(:id) { featured1.id }
        rswag_add_examples!
        run_test! { expect(FeaturedTag).to have_attributes(count: 2) }
      end

      response(403, 'Outside token scope') do
        schema '$ref' => '#/components/schemas/Error'
        include_context 'user token auth' do
          let(:user_token_scopes) { 'write:bookmarks' }
        end
        let!(:featured1) { Fabricate(:featured_tag, account: user.account, tag: tag1, name: "#{tag1.name}_featured") }
        let!(:featured2) { Fabricate(:featured_tag, account: user.account, tag: tag2, name: "#{tag2.name}_featured") }
        let(:id) { featured1.id }
        rswag_add_examples!
        run_test! { expect(FeaturedTag).to have_attributes(count: 2) }
      end
    end
  end
end
