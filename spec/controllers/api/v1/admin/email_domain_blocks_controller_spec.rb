# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Admin::EmailDomainBlocksController do
  render_views

  let(:role)    { UserRole.find_by(name: 'Admin') }
  let(:user)    { Fabricate(:user, role: role) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:account) { Fabricate(:account) }
  let(:scopes)  { 'admin:read:email_domain_blocks admin:write:email_domain_blocks' }

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

      it_behaves_like 'forbidden for wrong scope', 'read:statuses'
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

    context 'when there is no email domain block' do
      it 'returns an empty list' do
        get :index

        json = body_as_json

        expect(json).to be_empty
      end
    end

    context 'when there are email domain blocks' do
      let!(:email_domain_blocks) { Fabricate.times(5, :email_domain_block) }
      let(:blocked_email_domains) { email_domain_blocks.pluck(:domain) }

      it 'return the correct blocked email domains' do
        get :index

        json = body_as_json

        expect(json.pluck(:domain)).to match_array(blocked_email_domains)
      end

      context 'with limit param' do
        let(:params) { { limit: 2 } }

        it 'returns only the requested number of email domain blocks' do
          get :index, params: params

          json = body_as_json

          expect(json.size).to eq(params[:limit])
        end
      end

      context 'with since_id param' do
        let(:params) { { since_id: email_domain_blocks[1].id } }

        it 'returns only the email domain blocks after since_id' do
          get :index, params: params

          email_domain_blocks_ids = email_domain_blocks.pluck(:id).map(&:to_s)
          json = body_as_json

          expect(json.pluck(:id)).to match_array(email_domain_blocks_ids[2..])
        end
      end

      context 'with max_id param' do
        let(:params) { { max_id: email_domain_blocks[3].id } }

        it 'returns only the email domain blocks before max_id' do
          get :index, params: params

          email_domain_blocks_ids = email_domain_blocks.pluck(:id).map(&:to_s)
          json = body_as_json

          expect(json.pluck(:id)).to match_array(email_domain_blocks_ids[..2])
        end
      end
    end
  end

  describe 'GET #show' do
    let!(:email_domain_block) { Fabricate(:email_domain_block) }
    let(:params) { { id: email_domain_block.id } }

    context 'with wrong scope' do
      before do
        get :show, params: params
      end

      it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    end

    context 'with wrong role' do
      before do
        get :show, params: params
      end

      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'forbidden for wrong role', 'Moderator'
    end

    context 'when email domain block exists' do
      it 'returns http success' do
        get :show, params: params

        expect(response).to have_http_status(200)
      end

      it 'returns the correct blocked domain' do
        get :show, params: params

        json = body_as_json

        expect(json[:domain]).to eq(email_domain_block.domain)
      end
    end

    context 'when email domain block does not exist' do
      it 'returns http not found' do
        get :show, params: { id: 0 }

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST #create' do
    let(:params) { { domain: 'example.com' } }

    context 'with wrong scope' do
      before do
        post :create, params: params
      end

      it_behaves_like 'forbidden for wrong scope', 'read:statuses'
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

    it 'returns the correct blocked email domain' do
      post :create, params: params

      json = body_as_json

      expect(json[:domain]).to eq(params[:domain])
    end

    context 'when domain param is not provided' do
      let(:params) { { domain: '' } }

      it 'returns http unprocessable entity' do
        post :create, params: params

        expect(response).to have_http_status(422)
      end
    end

    context 'when provided domain name has an invalid character' do
      let(:params) { { domain: 'do\uD800.com' } }

      it 'returns http unprocessable entity' do
        post :create, params: params

        expect(response).to have_http_status(422)
      end
    end

    context 'when provided domain is already blocked' do
      before do
        EmailDomainBlock.create(params)
      end

      it 'returns http unprocessable entity' do
        post :create, params: params

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:email_domain_block) { Fabricate(:email_domain_block) }
    let(:params) { { id: email_domain_block.id } }

    context 'with wrong scope' do
      before do
        delete :destroy, params: params
      end

      it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    end

    context 'with wrong role' do
      before do
        delete :destroy, params: params
      end

      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'forbidden for wrong role', 'Moderator'
    end

    it 'returns http success' do
      delete :destroy, params: params

      expect(response).to have_http_status(200)
    end

    it 'returns an empty body' do
      delete :destroy, params: params

      json = body_as_json

      expect(json).to be_empty
    end

    it 'deletes email domain block' do
      delete :destroy, params: params

      email_domain_block = EmailDomainBlock.find_by(id: params[:id])

      expect(email_domain_block).to be_nil
    end

    context 'when email domain block does not exist' do
      it 'returns http not found' do
        delete :destroy, params: { id: 0 }

        expect(response).to have_http_status(404)
      end
    end
  end
end
