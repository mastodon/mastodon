# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController, type: :controller do
  controller do
    include SignatureVerification

    def success
      head 200
    end

    def alternative_success
      head 200
    end
  end

  before do
    routes.draw { get 'success' => 'anonymous#success' }
  end

  context 'without signature header' do
    before do
      get :success
    end

    describe '#signed_request?' do
      it 'returns false' do
        expect(controller.signed_request?).to be false
      end
    end

    describe '#signed_request_account' do
      it 'returns nil' do
        expect(controller.signed_request_account).to be_nil
      end
    end
  end

  context 'with signature header' do
    let!(:author) { Fabricate(:account) }

    before do
      get :success

      fake_request = Request.new(:get, request.url)
      fake_request.on_behalf_of(author)

      request.headers.merge!(fake_request.headers)
    end

    describe '#signed_request?' do
      it 'returns true' do
        expect(controller.signed_request?).to be true
      end
    end

    describe '#signed_request_account' do
      it 'returns an account' do
        expect(controller.signed_request_account).to eq author
      end

      it 'returns nil when path does not match' do
        request.path = '/alternative-path'
        expect(controller.signed_request_account).to be_nil
      end

      it 'returns nil when method does not match' do
        post :success
        expect(controller.signed_request_account).to be_nil
      end
    end
  end
end
