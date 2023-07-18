# frozen_string_literal: true

require 'rails_helper'

describe Admin::CustomEmojisController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    subject { get :index }

    before do
      Fabricate(:custom_emoji)
    end

    it 'renders index page' do
      expect(subject).to have_http_status 200
      expect(subject).to render_template :index
    end
  end

  describe 'GET #new' do
    subject { get :new }

    it 'renders new page' do
      expect(subject).to have_http_status 200
      expect(subject).to render_template :new
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
