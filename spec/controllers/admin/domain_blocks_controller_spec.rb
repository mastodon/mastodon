require 'rails_helper'

RSpec.describe Admin::DomainBlocksController, type: :controller do
  render_views

  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  describe 'GET #new' do
    it 'assigns a new domain block' do
      get :new

      expect(assigns(:domain_block)).to be_instance_of(DomainBlock)
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      domain_block = Fabricate(:domain_block)
      get :show, params: { id: domain_block.id }

      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    it 'blocks the domain when succeeded to save' do
      allow(DomainBlockWorker).to receive(:perform_async).and_return(true)

      post :create, params: { domain_block: { domain: 'example.com', severity: 'silence' } }

      expect(DomainBlockWorker).to have_received(:perform_async)
      expect(flash[:notice]).to eq I18n.t('admin.domain_blocks.created_msg')
      expect(response).to redirect_to(admin_instances_path(limited: '1'))
    end

    it 'renders new when failed to save' do
      Fabricate(:domain_block, domain: 'example.com', severity: 'suspend')
      allow(DomainBlockWorker).to receive(:perform_async).and_return(true)

      post :create, params: { domain_block: { domain: 'example.com', severity: 'silence' } }

      expect(DomainBlockWorker).not_to have_received(:perform_async)
      expect(response).to render_template :new
    end

    it 'allows upgrading a block' do
      Fabricate(:domain_block, domain: 'example.com', severity: 'silence')
      allow(DomainBlockWorker).to receive(:perform_async).and_return(true)

      post :create, params: { domain_block: { domain: 'example.com', severity: 'silence', reject_media: true, reject_reports: true } }

      expect(DomainBlockWorker).to have_received(:perform_async)
      expect(flash[:notice]).to eq I18n.t('admin.domain_blocks.created_msg')
      expect(response).to redirect_to(admin_instances_path(limited: '1'))
    end
  end

  describe 'DELETE #destroy' do
    it 'unblocks the domain' do
      service = double(call: true)
      allow(UnblockDomainService).to receive(:new).and_return(service)
      domain_block = Fabricate(:domain_block)
      delete :destroy, params: { id: domain_block.id }

      expect(service).to have_received(:call).with(domain_block)
      expect(flash[:notice]).to eq I18n.t('admin.domain_blocks.destroyed_msg')
      expect(response).to redirect_to(admin_instances_path(limited: '1'))
    end
  end

  describe 'GET #export' do
    it 'renders instances' do
      Fabricate(:domain_block, domain: 'bad.domain', severity: 'silence', public_comment: 'bad')
      Fabricate(:domain_block, domain: 'worse.domain', severity: 'suspend', reject_media: true, reject_reports: true, public_comment: 'worse', obfuscate: true)

      get :export, params: { format: :csv }
      expect(response).to have_http_status(200)
      expect(response.body).to eq(IO.read(File.join(self.class.fixture_path, 'files/domain_blocks.csv')))
    end
  end

  describe 'POST #import' do
    it 'blocks imported domains' do
      allow(DomainBlockWorker).to receive(:perform_async).and_return(true)

      post :import, params: { admin_import: { data: fixture_file_upload('files/domain_blocks.csv') } }

      expect(response).to redirect_to(admin_instances_path(limited: '1'))
      expect(DomainBlockWorker).to have_received(:perform_async).exactly(2).times

      # Header should not be imported
      expect(DomainBlock.where(domain: '#domain').present?).to eq(false)

      # Domains should now be added
      get :export, params: { format: :csv }
      expect(response).to have_http_status(200)
      expect(response.body).to eq(IO.read(File.join(self.class.fixture_path, 'files/domain_blocks.csv')))
    end
  end
end
