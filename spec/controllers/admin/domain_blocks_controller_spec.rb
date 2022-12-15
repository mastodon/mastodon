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

  describe 'PUT #update' do
    let!(:remote_account) { Fabricate(:account, domain: 'example.com') }
    let(:domain_block)    { Fabricate(:domain_block, domain: 'example.com', severity: original_severity) }

    before do
      BlockDomainService.new.call(domain_block)
    end

    let(:subject) do
      post :update, params: { id: domain_block.id, domain_block: { domain: 'example.com', severity: new_severity } }
    end

    context 'downgrading a domain suspension to silence' do
      let(:original_severity) { 'suspend' }
      let(:new_severity)      { 'silence' }

      it 'changes the block severity' do
        expect { subject }.to change { domain_block.reload.severity }.from('suspend').to('silence')
      end

      it 'undoes individual suspensions' do
        expect { subject }.to change { remote_account.reload.suspended? }.from(true).to(false)
      end

      it 'performs individual silences' do
        expect { subject }.to change { remote_account.reload.silenced? }.from(false).to(true)
      end
    end

    context 'upgrading a domain silence to suspend' do
      let(:original_severity) { 'silence' }
      let(:new_severity)      { 'suspend' }

      it 'changes the block severity' do
        expect { subject }.to change { domain_block.reload.severity }.from('silence').to('suspend')
      end

      it 'undoes individual silences' do
        expect { subject }.to change { remote_account.reload.silenced? }.from(true).to(false)
      end

      it 'performs individual suspends' do
        expect { subject }.to change { remote_account.reload.suspended? }.from(false).to(true)
      end
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
end
