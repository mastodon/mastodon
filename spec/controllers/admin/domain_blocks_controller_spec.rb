# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DomainBlocksController do
  render_views

  before do
    sign_in Fabricate(:user, role: UserRole.find_by(name: 'Admin')), scope: :user
  end

  describe 'GET #new' do
    it 'assigns a new domain block' do
      get :new

      expect(assigns(:domain_block)).to be_instance_of(DomainBlock)
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #batch' do
    it 'blocks the domains when succeeded to save' do
      allow(DomainBlockWorker).to receive(:perform_async).and_return(true)

      post :batch, params: {
        save: '',
        form_domain_block_batch: {
          domain_blocks_attributes: {
            '0' => { enabled: '1', domain: 'example.com', severity: 'silence' },
            '1' => { enabled: '0', domain: 'mastodon.social', severity: 'suspend' },
            '2' => { enabled: '1', domain: 'mastodon.online', severity: 'suspend' },
          },
        },
      }

      expect(DomainBlockWorker).to have_received(:perform_async).exactly(2).times
      expect(flash[:notice]).to eq I18n.t('admin.domain_blocks.created_msg')
      expect(response).to redirect_to(admin_instances_path(limited: '1'))
    end
  end

  describe 'POST #create' do
    before do
      allow(DomainBlockWorker).to receive(:perform_async).and_return(true)
    end

    context 'with "silence" severity and no conflict' do
      before do
        post :create, params: { domain_block: { domain: 'example.com', severity: 'silence' } }
      end

      it 'records a block' do
        expect(DomainBlock.exists?(domain: 'example.com', severity: 'silence')).to be true
      end

      it 'calls DomainBlockWorker' do
        expect(DomainBlockWorker).to have_received(:perform_async)
      end

      it 'redirects with a success message' do
        expect(flash[:notice]).to eq I18n.t('admin.domain_blocks.created_msg')
        expect(response).to redirect_to(admin_instances_path(limited: '1'))
      end
    end

    context 'when the new domain block conflicts with an existing one' do
      before do
        Fabricate(:domain_block, domain: 'example.com', severity: 'suspend')
        post :create, params: { domain_block: { domain: 'example.com', severity: 'silence' } }
      end

      it 'does not record a block' do
        expect(DomainBlock.exists?(domain: 'example.com', severity: 'silence')).to be false
      end

      it 'does not call DomainBlockWorker' do
        expect(DomainBlockWorker).to_not have_received(:perform_async)
      end

      it 'renders new' do
        expect(response).to render_template :new
      end
    end

    context 'with "suspend" severity and no conflict' do
      context 'without a confirmation' do
        before do
          post :create, params: { domain_block: { domain: 'example.com', severity: 'suspend', reject_media: true, reject_reports: true } }
        end

        it 'does not record a block' do
          expect(DomainBlock.exists?(domain: 'example.com', severity: 'suspend')).to be false
        end

        it 'does not call DomainBlockWorker' do
          expect(DomainBlockWorker).to_not have_received(:perform_async)
        end

        it 'renders confirm_suspension' do
          expect(response).to render_template :confirm_suspension
        end
      end

      context 'with a confirmation' do
        before do
          post :create, params: { :domain_block => { domain: 'example.com', severity: 'suspend', reject_media: true, reject_reports: true }, 'confirm' => '' }
        end

        it 'records a block' do
          expect(DomainBlock.exists?(domain: 'example.com', severity: 'suspend')).to be true
        end

        it 'calls DomainBlockWorker' do
          expect(DomainBlockWorker).to have_received(:perform_async)
        end

        it 'redirects with a success message' do
          expect(flash[:notice]).to eq I18n.t('admin.domain_blocks.created_msg')
          expect(response).to redirect_to(admin_instances_path(limited: '1'))
        end
      end
    end

    context 'when upgrading an existing block' do
      before do
        Fabricate(:domain_block, domain: 'example.com', severity: 'silence')
      end

      context 'without a confirmation' do
        before do
          post :create, params: { domain_block: { domain: 'example.com', severity: 'suspend', reject_media: true, reject_reports: true } }
        end

        it 'does not record a block' do
          expect(DomainBlock.exists?(domain: 'example.com', severity: 'suspend')).to be false
        end

        it 'does not call DomainBlockWorker' do
          expect(DomainBlockWorker).to_not have_received(:perform_async)
        end

        it 'renders confirm_suspension' do
          expect(response).to render_template :confirm_suspension
        end
      end

      context 'with a confirmation' do
        before do
          post :create, params: { :domain_block => { domain: 'example.com', severity: 'suspend', reject_media: true, reject_reports: true }, 'confirm' => '' }
        end

        it 'updates the record' do
          expect(DomainBlock.exists?(domain: 'example.com', severity: 'suspend')).to be true
        end

        it 'calls DomainBlockWorker' do
          expect(DomainBlockWorker).to have_received(:perform_async)
        end

        it 'redirects with a success message' do
          expect(flash[:notice]).to eq I18n.t('admin.domain_blocks.created_msg')
          expect(response).to redirect_to(admin_instances_path(limited: '1'))
        end
      end
    end
  end

  describe 'PUT #update' do
    let!(:remote_account) { Fabricate(:account, domain: 'example.com') }
    let(:subject) do
      post :update, params: { :id => domain_block.id, :domain_block => { domain: 'example.com', severity: new_severity }, 'confirm' => '' }
    end
    let(:domain_block) { Fabricate(:domain_block, domain: 'example.com', severity: original_severity) }

    before do
      BlockDomainService.new.call(domain_block)
    end

    context 'when downgrading a domain suspension to silence' do
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

    context 'when upgrading a domain silence to suspend' do
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
      service = instance_double(UnblockDomainService, call: true)
      allow(UnblockDomainService).to receive(:new).and_return(service)
      domain_block = Fabricate(:domain_block)
      delete :destroy, params: { id: domain_block.id }

      expect(service).to have_received(:call).with(domain_block)
      expect(flash[:notice]).to eq I18n.t('admin.domain_blocks.destroyed_msg')
      expect(response).to redirect_to(admin_instances_path(limited: '1'))
    end
  end
end
