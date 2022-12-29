# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::FavouritesController do
  path '/api/v1/favourites' do
    get('list favourites') do
      tags 'Api', 'V1', 'Favourites'
      operationId 'v1FavouritesListFavourite'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
