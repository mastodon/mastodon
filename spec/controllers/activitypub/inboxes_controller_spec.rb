# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::InboxesController, type: :controller do
  let(:remote_account) { nil }

  before do
    allow(controller).to receive(:signed_request_account).and_return(remote_account)
  end

  describe 'POST #create' do
    context 'with signature' do
      let(:remote_account) { Fabricate(:account, domain: 'example.com', protocol: :activitypub) }

      before do
        post :create, body: '{}'
      end

      it 'returns http accepted' do
        expect(response).to have_http_status(202)
      end
    end

    context 'without signature' do
      before do
        post :create, body: '{}'
      end

      it 'returns http not authorized' do
        expect(response).to have_http_status(401)
      end
    end
  end
end
