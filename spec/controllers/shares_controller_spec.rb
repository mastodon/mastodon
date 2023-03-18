# frozen_string_literal: true

require 'rails_helper'

describe SharesController do
  render_views

  let(:user) { Fabricate(:user) }

  before { sign_in user }

  describe 'GTE #show' do
    subject(:body_classes) { assigns(:body_classes) }

    before { get :show, params: { title: 'test title', text: 'test text', url: 'url1 url2' } }

    it 'returns http success' do
      expect(response).to have_http_status 200
      expect(body_classes).to eq 'modal-layout compose-standalone'
    end
  end
end
