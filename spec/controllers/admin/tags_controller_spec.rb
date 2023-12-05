# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TagsController do
  render_views

  before do
    sign_in Fabricate(:user, role: UserRole.find_by(name: 'Admin'))
  end

  describe 'GET #show' do
    let!(:tag) { Fabricate(:tag) }

    before do
      get :show, params: { id: tag.id }
    end

    it 'returns status 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'PUT #update' do
    let!(:tag) { Fabricate(:tag, listable: false) }

    context 'with valid params' do
      it 'updates the tag' do
        put :update, params: { id: tag.id, tag: { listable: '1' } }

        expect(response).to redirect_to(admin_tag_path(tag.id))
        expect(tag.reload).to be_listable
      end
    end

    context 'with invalid params' do
      it 'does not update the tag' do
        put :update, params: { id: tag.id, tag: { name: 'cant-change-name' } }

        expect(response).to have_http_status(200)
        expect(response).to render_template(:show)
      end
    end
  end
end
