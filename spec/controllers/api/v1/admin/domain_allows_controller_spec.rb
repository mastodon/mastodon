# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::DomainAllowsController do
  render_views

  let(:role)   { UserRole.find_by(name: 'Admin') }
  let(:user)   { Fabricate(:user, role: role) }
  let(:scopes) { 'admin:read admin:write' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

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
    let!(:domain_allow) { Fabricate(:domain_allow) }

    before do
      get :index
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns the expected domain allows' do
      json = body_as_json
      expect(json.length).to eq 1
      expect(json[0][:id].to_i).to eq domain_allow.id
    end
  end

  describe 'GET #show' do
    let!(:domain_allow) { Fabricate(:domain_allow) }

    before do
      get :show, params: { id: domain_allow.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns expected domain name' do
      json = body_as_json
      expect(json[:domain]).to eq domain_allow.domain
    end
  end

  describe 'DELETE #destroy' do
    let!(:domain_allow) { Fabricate(:domain_allow) }

    before do
      delete :destroy, params: { id: domain_allow.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'deletes the block' do
      expect(DomainAllow.find_by(id: domain_allow.id)).to be_nil
    end
  end

  describe 'POST #create' do
    let!(:domain_allow) { Fabricate(:domain_allow, domain: 'example.com') }

    context do
      before do
        post :create, params: { domain: 'foo.bar.com' }
      end

      it_behaves_like 'forbidden for wrong scope', 'write:statuses'
      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'forbidden for wrong role', 'Moderator'

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'returns expected domain name' do
        json = body_as_json
        expect(json[:domain]).to eq 'foo.bar.com'
      end

      it 'creates a domain block' do
        expect(DomainAllow.find_by(domain: 'foo.bar.com')).to_not be_nil
      end
    end

    context 'with invalid domain name' do
      before do
        post :create, params: { domain: 'foo bar' }
      end

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(422)
      end
    end
  end
end
