# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::CustomEmojis' do
  let(:current_user) { Fabricate(:admin_user) }

  before { sign_in current_user }

  describe 'Listing existing emoji' do
    let!(:custom_emoji) { Fabricate :custom_emoji }

    it 'Shows records' do
      visit admin_custom_emojis_path

      expect(page)
        .to have_content(I18n.t('admin.custom_emojis.title'))
        .and have_content(custom_emoji.shortcode)
    end
  end

  describe 'Creating a new emoji' do
    it 'saves a new emoji record with valid attributes' do
      visit new_admin_custom_emoji_path
      expect(page)
        .to have_content(I18n.t('admin.custom_emojis.title'))

      expect { submit_form }
        .to_not change(CustomEmoji, :count)
      expect(page)
        .to have_content(/errors below/)

      fill_in I18n.t('admin.custom_emojis.shortcode'),
              with: 'test'
      attach_file 'custom_emoji_image',
                  Rails.root.join('spec', 'fixtures', 'files', 'emojo.png')

      expect { submit_form }
        .to change(CustomEmoji, :count).by(1)
    end

    def submit_form
      click_on I18n.t('admin.custom_emojis.upload')
    end
  end

  describe 'Performing batch updates' do
    before do
      visit admin_custom_emojis_path
    end

    context 'without selecting any records' do
      it 'displays a notice about selection' do
        click_on button_for_enable

        expect(page).to have_content(selection_error_text)
      end
    end

    def button_for_enable
      I18n.t('admin.custom_emojis.enable')
    end

    def selection_error_text
      I18n.t('admin.custom_emojis.no_emoji_selected')
    end
  end
end
