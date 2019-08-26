require 'rails_helper'

RSpec.describe Api::V1::HideReblogsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read') }

  describe 'GET #index' do
    context 'without token' do
      it 'returns http unauthorized' do
        get :index
        expect(response).to have_http_status :unauthorized
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
          expect(response).to have_http_status :forbidden
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
          expect(response).to have_http_status :unprocessable_entity
        end
      end

      context 'with read scope and valid resource owner' do
        before do
          allow(controller).to receive(:doorkeeper_token) do
            Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:accounts')
          end
        end

        it 'show follow relationships hiding reblogs' do
          follow_by_user_with_reblogs = Fabricate(:follow, account: user.account, show_reblogs: true)
          follow_by_user_without_reblogs = Fabricate(:follow, account: user.account, show_reblogs: false)
          follow_by_other = Fabricate(:follow)

          get :index

          expect(assigns(:accounts)).to match_array [follow_by_user_without_reblogs.target_account]
        end

        it 'adds pagination headers if necessary' do
          follow = Fabricate(:follow, account: user.account, show_reblogs: false)

          get :index, params: { limit: 1 }

          expect(response.headers['Link'].find_link(['rel', 'next']).href).to eq "http://test.host/api/v1/hide_reblogs?limit=1&max_id=#{follow.id}"
          expect(response.headers['Link'].find_link(['rel', 'prev']).href).to eq "http://test.host/api/v1/hide_reblogs?limit=1&min_id=#{follow.id}"
        end

        it 'does not add pagination headers if not necessary' do
          get :index

          expect(response.headers['Link']).to eq nil
        end
      end
    end
  end
end
