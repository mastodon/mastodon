# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::PhraseBlocksController do
  render_views

  before do
    sign_in Fabricate(:user, role: UserRole.find_by(name: 'Admin')), scope: :user
  end

  describe 'GET #index' do
    around do |example|
      default_per_page = PhraseBlock.default_per_page
      PhraseBlock.paginates_per 1
      example.run
      PhraseBlock.paginates_per default_per_page
    end

    it 'renders registration filters' do
      2.times { Fabricate(:phrase_block) }

      get :index, params: { page: 2 }

      assigned = assigns(:phrase_blocks)
      expect(assigned.count).to eq 1
      expect(assigned.klass).to be PhraseBlock
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #new' do
    it 'assigns a new phrase block' do
      get :new

      expect(assigns(:phrase_block)).to be_instance_of(PhraseBlock)
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    it 'returns to phrase blocks page when succeeded to save' do
      post :create, params: { phrase_block: { phrase: 'bitcoin.spam' } }

      expect(flash[:notice]).to eq I18n.t('admin.phrase_blocks.created_msg')
      expect(response).to redirect_to(admin_phrase_blocks_path)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns to phrase blocks page when succeeded destroying' do
      phrase_block = Fabricate(:phrase_block)
      delete :destroy, params: { id: phrase_block.id }

      expect(flash[:notice]).to eq I18n.t('admin.phrase_blocks.destroyed_msg')
      expect(response).to redirect_to(admin_phrase_blocks_path)
    end
  end
end
