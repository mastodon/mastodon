# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::IpBlocksController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'returns http success and renders view' do
      get :new

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid data' do
      it 'creates a new ip block and redirects' do
        expect do
          post :create, params: { ip_block: { ip: '1.1.1.1', severity: 'no_access', expires_in: 1.day.to_i.to_s } }
        end.to change(IpBlock, :count).by(1)

        expect(response).to redirect_to(admin_ip_blocks_path)
        expect(flash.notice).to match(I18n.t('admin.ip_blocks.created_msg'))
      end
    end

    context 'with invalid data' do
      it 'does not create new a ip block and renders new' do
        expect do
          post :create, params: { ip_block: { ip: '1.1.1.1' } }
        end.to_not change(IpBlock, :count)

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
      end
    end
  end
end
