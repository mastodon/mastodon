# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::FavouritesController do
  path '/api/v1/favourites' do
    get('list favourites') do
      description <<~MD
        **Statuses the user has favourited**
        
        See also statuses/:id/{favourite,unfavourite}
      MD
      tags 'Api', 'V1', 'Favourites'
      operationId 'v1FavouritesListFavourite'
      rswag_auth_scope %w(read read:favourites)
      rswag_page_params limit_desc: <<~MD
        Maximum number of results to return.  
        Defaults to 20 statuses.  
        Max 40 statuses.
      MD
      include_context 'user token auth' do
        let(:user_token_scopes) { 'read:favourites' }
      end
      let(:other1) { Fabricate(:user).account }
      let(:other2) { Fabricate(:account, domain: 'else.where') }
      let!(:status_one) { Fabricate(:status, account: other1) }
      let!(:status_two) { Fabricate(:status, account: other2, thread: status_one) }
      let!(:status_three) { Fabricate(:status, account: other1, thread: status_two) }
      let!(:status_four) { Fabricate(:status, account: other2, thread: status_three) }

      let!(:fav_one1) { user.account.favourites.create!(status: status_one) }
      let!(:fav_one2) { other1.favourites.create!(status: status_one) }
      let!(:fav_two1) { user.account.favourites.create!(status: status_two) }
      let!(:fav_two2) { other2.favourites.create!(status: status_two) }
      let!(:fav_three1) { user.account.favourites.create!(status: status_three) }
      let!(:fav_four1) { other1.favourites.create!(status: status_four) }

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Status' }
        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to have_attributes(size: 3).and(
            match_array(
              [
                include({ id: status_one.id.to_s }),
                include({ id: status_two.id.to_s }),
                include({ id: status_three.id.to_s }),
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
  end
end
