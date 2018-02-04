require 'rails_helper'

RSpec.describe Admin::DomainBlocksController, type: :controller do
  render_views

  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  describe 'GET #index' do
    around do |example|
      default_per_page = DomainBlock.default_per_page
      DomainBlock.paginates_per 1
      example.run
      DomainBlock.paginates_per default_per_page
    end

    it 'renders domain blocks' do
      2.times { Fabricate(:domain_block) }

      get :index, params: { page: 2 }

      assigned = assigns(:domain_blocks)
      expect(assigned.count).to eq 1
      expect(assigned.klass).to be DomainBlock
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'assigns a new domain block' do
      get :new

      expect(assigns(:domain_block)).to be_instance_of(DomainBlock)
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
    it 'blocks the domain when succeeded to save' do
      allow(DomainBlockWorker).to receive(:perform_async).and_return(true)

      post :create, params: { domain_block: { domain: 'example.com', severity: 'silence' } }

      expect(DomainBlockWorker).to have_received(:perform_async)
      expect(flash[:notice]).to eq I18n.t('admin.domain_blocks.created_msg')
      expect(response).to redirect_to(admin_domain_blocks_path)
    end

    it 'renders new when failed to save' do
      Fabricate(:domain_block, domain: 'example.com')
      allow(DomainBlockWorker).to receive(:perform_async).and_return(true)

      post :create, params: { domain_block: { domain: 'example.com', severity: 'silence' } }

      expect(DomainBlockWorker).not_to have_received(:perform_async)
      expect(response).to render_template :new
    end
  end

  describe 'DELETE #destroy' do
    it 'unblocks the domain' do
      service = double(call: true)
      allow(UnblockDomainService).to receive(:new).and_return(service)
      domain_block = Fabricate(:domain_block)
      delete :destroy, params: { id: domain_block.id, domain_block: { retroactive: '1' } }

      expect(service).to have_received(:call).with(domain_block, true)
      expect(flash[:notice]).to eq I18n.t('admin.domain_blocks.destroyed_msg')
      expect(response).to redirect_to(admin_domain_blocks_path)
    end
  end
end
