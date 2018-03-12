# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Notifications::UnreadsController, type: :controller do
  describe 'show' do
    subject { get :show }

    context 'when authorized' do
      let(:user) { Fabricate(:user) }
      let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read') }

      before do
        allow(controller).to receive(:doorkeeper_token) { token }
      end

      it 'shows unread notifications information' do
        subject
        expect(body_as_json).to eq({ count: 0, limit: 40 })
      end
    end

    context 'when unauthorized' do
      it { is_expected.to have_http_status :unauthorized }
    end
  end

  describe 'update' do
    context 'when authorized' do
      let(:user) { Fabricate(:user) }
      let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read') }

      before do
        allow(controller).to receive(:doorkeeper_token) { token }
      end

      it 'shows unread notifications information' do
        get :update
        expect(body_as_json).to eq({ count: 0, limit: 40 })
      end

      it 'updates last read ID' do
        get :update, params: { last_read_id: 42 }
        expect(user.reload.last_read_notification_id).to eq 42
      end

      it 'updates reading state' do
        get :update, params: { reading: true }
        expect(token.reload.reading_notifications).to eq true
      end
    end

    context 'when unauthorized' do
      subject { get :update }
      it { is_expected.to have_http_status :unauthorized }
    end
  end
end
