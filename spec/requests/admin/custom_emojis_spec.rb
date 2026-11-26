# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Custom Emojis' do
  describe 'GET /admin/custom_emojis' do
    before { sign_in Fabricate(:admin_user) }

    it 'gives the local filter precedence over remote and domain filters' do
      get admin_custom_emojis_path(local: '1', remote: '1', by_domain: 'example.org')

      expect(response)
        .to have_http_status(200)
      expect(response.body)
        .to have_link(I18n.t('admin.accounts.location.local'), class: 'selected')
        .and have_no_field('by_domain')
    end

    it 'ignores inactive location flags' do
      get admin_custom_emojis_path(local: '0', remote: '0')

      expect(response)
        .to have_http_status(200)
      expect(response.body)
        .to have_link(I18n.t('admin.accounts.location.all'), class: 'selected')
    end
  end

  describe 'POST /admin/custom_emojis/batch' do
    let(:custom_emoji) { Fabricate(:custom_emoji, shortcode: 'wave', domain: 'example.org', disabled: false) }

    before { sign_in Fabricate(:admin_user) }

    it 'preserves filters and pagination after a successful batch submission' do
      expect do
        post batch_admin_custom_emojis_path, params: {
          remote: '1',
          by_domain: 'example.org',
          shortcode: 'wave',
          page: '2',
          disable: '1',
          form_custom_emoji_batch: { custom_emoji_ids: [custom_emoji.id] },
        }
      end.to change { custom_emoji.reload.disabled }.from(false).to(true)

      expect(response)
        .to redirect_to(admin_custom_emojis_path(remote: '1', by_domain: 'example.org', shortcode: 'wave', page: '2'))
    end

    it 'preserves normalized local filters on redirect' do
      post batch_admin_custom_emojis_path(local: '1', remote: '1', by_domain: 'example.org', shortcode: 'wave')

      expect(response)
        .to redirect_to(admin_custom_emojis_path(local: '1', shortcode: 'wave'))
    end

    it 'infers the remote filter from the domain on redirect' do
      post batch_admin_custom_emojis_path(by_domain: 'example.org', shortcode: 'wave')

      expect(response)
        .to redirect_to(admin_custom_emojis_path(remote: '1', by_domain: 'example.org', shortcode: 'wave'))
    end
  end

  describe 'POST /admin/custom_emojis' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_custom_emojis_path(custom_emoji: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
