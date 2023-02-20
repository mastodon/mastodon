require 'rails_helper'

RSpec.describe Api::V1::FavouritesController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read') }

  describe 'GET #index' do
    context 'without token' do
      it 'returns http unauthorized' do
        get :index
        expect(response).to have_http_status 401
      end
    end

    context 'with token' do
      context 'without read scope' do
        before do
          allow(controller).to receive(:doorkeeper_token) do
            Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: '')
          end
        end

        it 'returns http forbidden' do
          get :index
          expect(response).to have_http_status 403
        end
      end

      context 'without valid resource owner' do
        before do
          token = Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read')
          user.destroy!

          allow(controller).to receive(:doorkeeper_token) { token }
        end

        it 'returns http unprocessable entity' do
          get :index
          expect(response).to have_http_status 422
        end
      end

      context 'with read scope and valid resource owner' do
        before do
          allow(controller).to receive(:doorkeeper_token) do
            Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:favourites')
          end
        end

        it 'shows favourites owned by the user' do
          favourite_by_user = Fabricate(:favourite, account: user.account)
          favourite_by_others = Fabricate(:favourite)

          get :index

          expect(assigns(:statuses)).to match_array [favourite_by_user.status]
        end

        it 'adds pagination headers if necessary' do
          favourite = Fabricate(:favourite, account: user.account)

          get :index, params: { limit: 1 }

          expect(response.headers['Link'].find_link(%w(rel next)).href).to eq "http://test.host/api/v1/favourites?limit=1&max_id=#{favourite.id}"
          expect(response.headers['Link'].find_link(%w(rel prev)).href).to eq "http://test.host/api/v1/favourites?limit=1&min_id=#{favourite.id}"
        end

        it 'does not add pagination headers if not necessary' do
          get :index

          expect(response.headers['Link']).to be_nil
        end
      end
    end
  end
end
