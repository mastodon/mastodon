# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::CustomEmojisController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    before do
      Fabricate(:custom_emoji)
    end

    it 'renders index page' do
      get :index

      expect(response).to have_http_status 200
      expect(response).to render_template :index
    end
  end

  describe 'GET #new' do
    it 'renders new page' do
      get :new

      expect(response).to have_http_status 200
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    subject { post :create, params: { custom_emoji: params } }

    let(:image) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'emojo.png'), 'image/png') }

    context 'when parameter is valid' do
      let(:params) { { shortcode: 'test', image: image } }

      it 'creates custom emoji' do
        expect { subject }.to change(CustomEmoji, :count).by(1)
      end
    end

    context 'when parameter is invalid' do
      let(:params) { { shortcode: 't', image: image } }

      it 'renders new' do
        expect(subject).to render_template :new
      end
    end
  end
end
