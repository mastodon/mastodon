require 'rails_helper'

RSpec.describe Admin::DomainBlocksController, type: :controller do
  render_views

  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      domain_block = Fabricate(:domain_block)
      get :show, params: { id: domain_block.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'blocks the domain' do
      allow(DomainBlockWorker).to receive(:perform_async).and_return(true)
      post :create, params: { domain_block: { domain: 'example.com', severity: 'silence' } }

      expect(DomainBlockWorker).to have_received(:perform_async)
      expect(response).to redirect_to(admin_domain_blocks_path)
    end
  end

  describe 'DELETE #destroy' do
    it 'unblocks the domain' do
      service = double(call: true)
      allow(UnblockDomainService).to receive(:new).and_return(service)
      domain_block = Fabricate(:domain_block)
      delete :destroy, params: { id: domain_block.id, domain_block: { retroactive: '1' } }

      expect(service).to have_received(:call).with(domain_block, true)
      expect(response).to redirect_to(admin_domain_blocks_path)
    end
  end
end
