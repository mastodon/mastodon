# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::InboxesController, type: :controller do
  describe 'POST #create' do
    context 'if signed_request_account' do
      it 'returns 202' do
        allow(controller).to receive(:signed_request_account) do
          Fabricate(:account)
        end

        post :create, body: '{}'
        expect(response).to have_http_status(202)
      end
    end

    context 'not signed_request_account' do
      it 'returns 401' do
        allow(controller).to receive(:signed_request_account) do
          false
        end

        post :create, body: '{}'
        expect(response).to have_http_status(401)
      end
    end
  end
end
