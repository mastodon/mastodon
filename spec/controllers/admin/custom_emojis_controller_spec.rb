require 'rails_helper'

describe Admin::CustomEmojisController do
  render_views

  let(:user) { Fabricate(:user, admin: true) }

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
        expect { subject }.to change { CustomEmoji.count }.by(1)
      end
    end

    context 'when parameter is invalid' do
      let(:params) { { shortcode: 't', image: image } }

      it 'renders new' do
        expect(subject).to render_template :new
      end
    end
  end

  describe 'PUT #update' do
    let(:custom_emoji) { Fabricate(:custom_emoji, shortcode: 'test') }
    let(:image) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'emojo.png'), 'image/png') }

    before do
      put :update, params: { id: custom_emoji.id, custom_emoji: params }
    end

    context 'when parameter is valid' do
      let(:params) { { shortcode: 'updated', image: image } }

      it 'succeeds in updating custom emoji' do
        expect(flash[:notice]).to eq I18n.t('admin.custom_emojis.updated_msg')
        expect(custom_emoji.reload).to have_attributes(shortcode: 'updated')
      end
    end

    context 'when parameter is invalid' do
      let(:params) { { shortcode: 'u', image: image } }

      it 'fails to update custom emoji' do
        expect(flash[:alert]).to eq I18n.t('admin.custom_emojis.update_failed_msg')
        expect(custom_emoji.reload).to have_attributes(shortcode: 'test')
      end
    end
  end

  describe 'POST #copy' do
    subject { post :copy, params: { id: custom_emoji.id } }

    let(:custom_emoji) { Fabricate(:custom_emoji, shortcode: 'test') }

    it 'copies custom emoji' do
      expect { subject }.to change { CustomEmoji.where(shortcode: 'test').count }.by(1)
      expect(flash[:notice]).to eq I18n.t('admin.custom_emojis.copied_msg')
    end
  end

  describe 'POST #enable' do
    let(:custom_emoji) { Fabricate(:custom_emoji, shortcode: 'test', disabled: true) }

    before { post :enable, params: { id: custom_emoji.id } }

    it 'enables custom emoji' do
      expect(response).to redirect_to admin_custom_emojis_path
      expect(custom_emoji.reload).to have_attributes(disabled: false)
    end
  end

  describe 'POST #disable' do
    let(:custom_emoji) { Fabricate(:custom_emoji, shortcode: 'test', disabled: false) }

    before { post :disable, params: { id: custom_emoji.id } }

    it 'enables custom emoji' do
      expect(response).to redirect_to admin_custom_emojis_path
      expect(custom_emoji.reload).to have_attributes(disabled: true)
    end
  end
end
