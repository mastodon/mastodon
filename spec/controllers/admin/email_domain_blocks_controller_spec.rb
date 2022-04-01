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

    it 'returns http success' do
      2.times { Fabricate(:email_domain_block) }
      get :index, params: { page: 2 }
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    context 'when resolve button is pressed' do
      before do
        post :create, params: { email_domain_block: { domain: 'example.com' } }
      end

      it 'renders new template' do
        expect(response).to render_template(:new)
      end
    end

    context 'when save button is pressed' do
      before do
        post :create, params: { email_domain_block: { domain: 'example.com' }, save: '' }
      end

      it 'blocks the domain' do
        expect(EmailDomainBlock.find_by(domain: 'example.com')).to_not be_nil
      end

      it 'redirects to e-mail domain blocks' do
        expect(response).to redirect_to(admin_email_domain_blocks_path)
      end
    end
  end
end
