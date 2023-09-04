# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Announcements::ReactionsController, type: :controller do
  render_views

  let(:user)   { Fabricate(:user) }
  let(:scopes) { 'write:favourites' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

  let!(:announcement) { Fabricate(:announcement) }

  describe 'PUT #update' do
    context 'without token' do
      it 'returns http unauthorized' do
        put :update, params: { announcement_id: announcement.id, id: '😂' }
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with token' do
      before do
        allow(controller).to receive(:doorkeeper_token) { token }
        put :update, params: { announcement_id: announcement.id, id: '😂' }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'creates reaction' do
        expect(announcement.announcement_reactions.find_by(name: '😂', account: user.account)).to_not be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      announcement.announcement_reactions.create!(account: user.account, name: '😂')
    end

    context 'without token' do
      it 'returns http unauthorized' do
        delete :destroy, params: { announcement_id: announcement.id, id: '😂' }
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with token' do
      before do
        allow(controller).to receive(:doorkeeper_token) { token }
        delete :destroy, params: { announcement_id: announcement.id, id: '😂' }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'creates reaction' do
        expect(announcement.announcement_reactions.find_by(name: '😂', account: user.account)).to be_nil
      end
    end
  end
end
