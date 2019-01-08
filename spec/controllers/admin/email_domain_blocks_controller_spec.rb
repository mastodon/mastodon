# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::EmailDomainBlocksController, type: :controller do
  render_views

  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  describe 'GET #index' do
    around do |example|
      default_per_page = EmailDomainBlock.default_per_page
      EmailDomainBlock.paginates_per 1
      example.run
      EmailDomainBlock.paginates_per default_per_page
    end

    it 'renders email blacks' do
      2.times { Fabricate(:email_domain_block) }

      get :index, params: { page: 2 }

      assigned = assigns(:email_domain_blocks)
      expect(assigned.count).to eq 1
      expect(assigned.klass).to be EmailDomainBlock
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #new' do
    it 'assigns a new email black' do
      get :new

      expect(assigns(:email_domain_block)).to be_instance_of(EmailDomainBlock)
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    it 'blocks the domain when succeeded to save' do
      post :create, params: { email_domain_block: { domain: 'example.com'} }

      expect(flash[:notice]).to eq I18n.t('admin.email_domain_blocks.created_msg')
      expect(response).to redirect_to(admin_email_domain_blocks_path)
    end
  end

  describe 'DELETE #destroy' do
    it 'unblocks the domain' do
      email_domain_block = Fabricate(:email_domain_block)
      delete :destroy, params: { id: email_domain_block.id } 

      expect(flash[:notice]).to eq I18n.t('admin.email_domain_blocks.destroyed_msg')
      expect(response).to redirect_to(admin_email_domain_blocks_path)
    end
  end
end
