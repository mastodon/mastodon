# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Admin::IpBlocksController do
  render_views

  let(:role)    { UserRole.find_by(name: 'Admin') }
  let(:user)    { Fabricate(:user, role: role) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'admin:read:ip_blocks admin:write:ip_blocks' }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  shared_examples 'forbidden for wrong scope' do |wrong_scope|
    let(:scopes) { wrong_scope }

    it 'returns http forbidden' do
      expect(response).to have_http_status(403)
    end
  end

  shared_examples 'forbidden for wrong role' do |wrong_role|
    let(:role) { UserRole.find_by(name: wrong_role) }

    it 'returns http forbidden' do
      expect(response).to have_http_status(403)
    end
  end

  describe 'GET #index' do
    context 'with wrong scope' do
      before do
        get :index
      end

      it_behaves_like 'forbidden for wrong scope', 'admin:write:ip_blocks'
    end

    context 'with wrong role' do
      before do
        get :index
      end

      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'forbidden for wrong role', 'Moderator'
    end

    it 'returns http success' do
      get :index

      expect(response).to have_http_status(200)
    end

    context 'when there is no ip block' do
      it 'returns an empty body' do
        get :index

        json = body_as_json

        expect(json).to be_empty
      end
    end

    context 'when there are ip blocks' do
      let!(:ip_blocks) do
        [
          IpBlock.create(ip: '192.0.2.0/24', severity: :no_access),
          IpBlock.create(ip: '172.16.0.1', severity: :sign_up_requires_approval, comment: 'Spam'),
          IpBlock.create(ip: '2001:0db8::/32', severity: :sign_up_block, expires_in: 10.days),
        ]
      end
      let(:expected_response) do
        ip_blocks.map do |ip_block|
          {
            id: ip_block.id.to_s,
            ip: ip_block.ip,
            severity: ip_block.severity.to_s,
            comment: ip_block.comment,
            created_at: ip_block.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ'),
            expires_at: ip_block.expires_at&.strftime('%Y-%m-%dT%H:%M:%S.%LZ'),
          }
        end
      end

      it 'returns the correct blocked ips' do
        get :index

        json = body_as_json

        expect(json).to match_array(expected_response)
      end

      context 'with limit param' do
        let(:params) { { limit: 2 } }

        it 'returns only the requested number of ip blocks' do
          get :index, params: params

          json = body_as_json

          expect(json.size).to eq(params[:limit])
        end
      end
    end
  end

  describe 'GET #show' do
    let!(:ip_block) { IpBlock.create(ip: '192.0.2.0/24', severity: :no_access) }
    let(:params) { { id: ip_block.id } }

    context 'with wrong scope' do
      before do
        get :show, params: params
      end

      it_behaves_like 'forbidden for wrong scope', 'admin:write:ip_blocks'
    end

    context 'with wrong role' do
      before do
        get :show, params: params
      end

      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'forbidden for wrong role', 'Moderator'
    end

    it 'returns http success' do
      get :show, params: params

      expect(response).to have_http_status(200)
    end

    it 'returns the correct ip block' do
      get :show, params: params

      json = body_as_json

      expect(json[:ip]).to eq("#{ip_block.ip}/#{ip_block.ip.prefix}")
      expect(json[:severity]).to eq(ip_block.severity.to_s)
    end

    context 'when ip block does not exist' do
      it 'returns http not found' do
        get :show, params: { id: 0 }

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST #create' do
    let(:params) { { ip: '151.0.32.55', severity: 'no_access', comment: 'Spam' } }

    context 'with wrong scope' do
      before do
        post :create, params: params
      end

      it_behaves_like 'forbidden for wrong scope', 'admin:read:ip_blocks'
    end

    context 'with wrong role' do
      before do
        post :create, params: params
      end

      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'forbidden for wrong role', 'Moderator'
    end

    it 'returns http success' do
      post :create, params: params

      expect(response).to have_http_status(200)
    end

    it 'returns the correct ip block' do
      post :create, params: params

      json = body_as_json

      expect(json[:ip]).to eq("#{params[:ip]}/32")
      expect(json[:severity]).to eq(params[:severity])
      expect(json[:comment]).to eq(params[:comment])
    end

    context 'when ip is not provided' do
      let(:params) { { ip: '', severity: 'no_access' } }

      it 'returns http unprocessable entity' do
        post :create, params: params

        expect(response).to have_http_status(422)
      end
    end

    context 'when severity is not provided' do
      let(:params) { { ip: '173.65.23.1', severity: '' } }

      it 'returns http unprocessable entity' do
        post :create, params: params

        expect(response).to have_http_status(422)
      end
    end

    context 'when provided ip is already blocked' do
      before do
        IpBlock.create(params)
      end

      it 'returns http unprocessable entity' do
        post :create, params: params

        expect(response).to have_http_status(422)
      end
    end

    context 'when provided ip address is invalid' do
      let(:params) { { ip: '520.13.54.120', severity: 'no_access' } }

      it 'returns http unprocessable entity' do
        post :create, params: params

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT #update' do
    context 'when ip block exists' do
      let!(:ip_block) { IpBlock.create(ip: '185.200.13.3', severity: 'no_access', comment: 'Spam', expires_in: 48.hours) }
      let(:params) { { id: ip_block.id, severity: 'sign_up_requires_approval', comment: 'Decreasing severity' } }

      it 'returns http success' do
        put :update, params: params

        expect(response).to have_http_status(200)
      end

      it 'returns the correct ip block' do
        put :update, params: params

        json = body_as_json

        expect(json).to match(hash_including({
          ip: "#{ip_block.ip}/#{ip_block.ip.prefix}",
          severity: 'sign_up_requires_approval',
          comment: 'Decreasing severity',
        }))
      end

      it 'updates the severity correctly' do
        expect { put :update, params: params }.to change { ip_block.reload.severity }.from('no_access').to('sign_up_requires_approval')
      end

      it 'updates the comment correctly' do
        expect { put :update, params: params }.to change { ip_block.reload.comment }.from('Spam').to('Decreasing severity')
      end
    end

    context 'when ip block does not exist' do
      it 'returns http not found' do
        put :update, params: { id: 0 }

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when ip block exists' do
      let!(:ip_block) { IpBlock.create(ip: '185.200.13.3', severity: 'no_access') }
      let(:params) { { id: ip_block.id } }

      it 'returns http success' do
        delete :destroy, params: params

        expect(response).to have_http_status(200)
      end

      it 'returns an empty body' do
        delete :destroy, params: params

        json = body_as_json

        expect(json).to be_empty
      end

      it 'deletes the ip block' do
        delete :destroy, params: params

        expect(IpBlock.find_by(id: ip_block.id)).to be_nil
      end
    end

    context 'when ip block does not exist' do
      it 'returns http not found' do
        delete :destroy, params: { id: 0 }

        expect(response).to have_http_status(404)
      end
    end
  end
end
