# frozen_string_literal: true

require 'rails_helper'

describe Admin::CustomEmojisController, type: :controller do
  render_views

  before { sign_in Fabricate(:user, admin: true) }

  describe 'GET #index' do
    it 'renders shortcode and associated deletion path' do
      emojo = Fabricate(:custom_emoji, domain: nil, shortcode: 'emojo')

      get :index

      expect(response.body).to include ':emojo:'
      expect(response.body).to include admin_custom_emoji_path(emojo)
    end

    it 'does not render shortcode and associated deletion path of remote emojis' do
      emojo = Fabricate(
        :custom_emoji,
        domain: Faker::Internet.domain_name,
        shortcode: 'emojo'
      )

      get :index

      expect(response.body).not_to include ':emojo:'
      expect(response.body).not_to include admin_custom_emoji_path(emojo)
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status :success
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status :success
    end
  end

  describe 'POST #create' do
    it 'creates custom emoji' do
      post :create, params: { custom_emoji: { shortcode: 'shortcode', custom_emoji_icon: { image: fixture_file_upload('files/emojo.png') } } }

      expect(CustomEmoji.joins(:custom_emoji_icon).where(domain: nil, shortcode: 'shortcode', custom_emoji_icons: { uri: nil })).to exist
    end

    it 'redirects to index with notice' do
      post :create, params: { custom_emoji: { shortcode: 'shortcode', custom_emoji_icon: { image: fixture_file_upload('files/emojo.png') } } }

      expect(flash[:notice]).to eq I18n.t('admin.custom_emojis.created_msg')
      expect(response).to redirect_to admin_custom_emojis_path
    end

    it 'returns http success even if validation failed' do
      post :create, params: { custom_emoji: { shortcode: 'a', custom_emoji_icon: { image: fixture_file_upload('files/emojo.png') } } }
      expect(response).to have_http_status :success
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys custom emoji' do
      custom_emoji = Fabricate(:custom_emoji, domain: nil)
      delete :destroy, params: { id: custom_emoji }
      expect { custom_emoji.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'destroys custom emoji icon as well if it is local' do
      custom_emoji_icon = Fabricate(:custom_emoji_icon, uri: nil)
      custom_emoji = Fabricate(:custom_emoji, custom_emoji_icon: custom_emoji_icon)

      delete :destroy, params: { id: custom_emoji }

      expect { custom_emoji_icon.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'redirects to index with notice' do
      custom_emoji = Fabricate(:custom_emoji, domain: nil)

      delete :destroy, params: { id: custom_emoji }

      expect(flash[:notice]).to eq I18n.t('admin.custom_emojis.destroyed_msg')
      expect(response).to redirect_to admin_custom_emojis_path
    end
  end
end
