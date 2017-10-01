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

  describe 'GET #import_form' do
    context 'when the URL of the status is not specified' do
      it 'redirects to index with error message' do
        get :import_form
        expect(response).to redirect_to admin_custom_emojis_url(flash: { error: I18n.t('admin.custom_emojis.status_unspecified_msg') })
      end
    end

    context 'when no status was found at the specified URL' do
      it 'redirects to index with error message' do
        get :import_form, params: { status: { url: 'invalid URL' } }
        expect(response).to redirect_to admin_custom_emojis_url(flash: { error: I18n.t('admin.custom_emojis.status_not_found_msg') })
      end
    end

    context 'when the specified URL points something else status' do
      it 'redirects to index with error message' do
        Fabricate(:account, domain: nil, username: 'username')
        get :import_form, params: { status: { url: 'http://cb6e6126.ngrok.io/@username' } }
        expect(response).to redirect_to admin_custom_emojis_url(flash: { error: I18n.t('admin.custom_emojis.status_not_found_msg') })
      end
    end

    context 'when valid status URL is specified' do
      let(:account) { Fabricate(:account, domain: 'remote.account.domain') }
      let(:status) { Fabricate(:status, account: account, text: ':emojo:') }
      let(:url) { "http://cb6e6126.ngrok.io#{short_account_status_path(status.account.username, status)}" }

      context 'with emojis' do
        let(:custom_emoji_icon) do
          stub_request(:get, 'https://remote/custom/emojo/icon/image').to_return body: attachment_fixture('emojo.png')

          Fabricate(
            :custom_emoji_icon,
            uri: 'https://remote/custom/emojo/icon',
            image_remote_url: 'https://remote/custom/emojo/icon/image'
          )
        end

        let!(:custom_emoji) do
          Fabricate(
            :custom_emoji,
            custom_emoji_icon: custom_emoji_icon,
            domain: 'remote.account.domain',
            shortcode: 'emojo'
          )
        end

        it 'does not render emojis already imported' do
          Fabricate(:custom_emoji, custom_emoji_icon: custom_emoji_icon, domain: nil)
          get :import_form, params: { status: { url: url } }
          expect(response.body).not_to include ':emojo:'
        end

        it 'renders emojis' do
          get :import_form, params: { status: { url: url } }
          expect(response.body).to include ':emojo:'
        end
      end

      it 'renders status id' do
        get :import_form, params: { status: { url: url } }
        expect(response.body).to include status.id.to_s
      end

      it 'returns http success' do
        get :import_form, params: { status: { url: url } }
        expect(response).to have_http_status :success
      end
    end
  end

  describe 'GET #upload_form' do
    it 'returns http success' do
      get :upload_form
      expect(response).to have_http_status :success
    end
  end

  describe 'POST #import' do
    context 'when custom emoji is not specified' do
      it 'renders import form with error message' do
        post :import, params: { status: { id: Fabricate(:status) } }
        expect(flash[:error]).to eq I18n.t('admin.custom_emojis.emoji_unspecified_msg')
      end
    end

    context 'when specified custom emoji does not exist' do
      it 'renders import form with error message' do
        post :import, params: { custom_emoji: { super_id: 42 }, status: { id: Fabricate(:status) } }
        expect(flash[:error]).to eq I18n.t('admin.custom_emojis.emoji_not_found_msg')
      end
    end

    context 'when specified custom emoji exists' do
      let(:super_custom_emoji) { Fabricate(:custom_emoji, domain: Faker::Internet.domain_name, shortcode: 'shortcode') }

      it 'creates custom emoji' do
        post :import, params: { custom_emoji: { super_id: super_custom_emoji } }
        expect(CustomEmoji.joins(:custom_emoji_icon).where(custom_emoji_icon: super_custom_emoji.custom_emoji_icon, domain: nil, shortcode: 'shortcode')).to exist
      end

      it 'overrides shortcode if provided' do
        post :import, params: { custom_emoji: { shortcode: 'overriden', super_id: super_custom_emoji } }
        expect(CustomEmoji.joins(:custom_emoji_icon).where(custom_emoji_icon: super_custom_emoji.custom_emoji_icon, domain: nil, shortcode: 'overriden')).to exist
      end

      it 'redirects to index with notice' do
        post :import, params: { custom_emoji: { super_id: super_custom_emoji } }

        expect(flash[:notice]).to eq I18n.t('admin.custom_emojis.created_msg')
        expect(response).to redirect_to admin_custom_emojis_path
      end

      it 'returns http success even if validation failed' do
        Fabricate(:custom_emoji, domain: nil, shortcode: 'shortcode')

        post :import, params: { custom_emoji: { super_id: super_custom_emoji }, status: { id: Fabricate(:status) } }
        expect(response).to have_http_status :success
      end
    end

    it 'redirects to index with error message if there is an error and the status is not found' do
      post :import, params: { status: { id: 42 } }
      expect(response).to redirect_to admin_custom_emojis_url(flash: { error: I18n.t('admin.custom_emojis.status_not_found_msg') })
    end
  end

  describe 'POST #upload' do
    it 'creates custom emoji' do
      post :upload, params: { custom_emoji: { shortcode: 'shortcode', custom_emoji_icon: { image: fixture_file_upload('files/emojo.png') } } }

      expect(CustomEmoji.joins(:custom_emoji_icon).where(domain: nil, shortcode: 'shortcode', custom_emoji_icons: { uri: nil })).to exist
    end

    it 'redirects to index with notice' do
      post :upload, params: { custom_emoji: { shortcode: 'shortcode', custom_emoji_icon: { image: fixture_file_upload('files/emojo.png') } } }

      expect(flash[:notice]).to eq I18n.t('admin.custom_emojis.created_msg')
      expect(response).to redirect_to admin_custom_emojis_path
    end

    it 'returns http success even if validation failed' do
      post :upload, params: { custom_emoji: { shortcode: 'a', custom_emoji_icon: { image: fixture_file_upload('files/emojo.png') } } }
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
