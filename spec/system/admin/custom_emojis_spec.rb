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
        .to have_text(I18n.t('admin.custom_emojis.title'))
        .and have_text(custom_emoji.shortcode)
    end
  end

  describe 'Filtering emoji' do
    let!(:local_emoji) { Fabricate(:custom_emoji, shortcode: 'local_wave') }
    let!(:remote_emoji) { Fabricate(:custom_emoji, shortcode: 'remote_wave', domain: 'example.org') }
    let!(:other_remote_emoji) { Fabricate(:custom_emoji, shortcode: 'remote_smile', domain: 'other.example') }

    it 'keeps the local filter selected when clicked again' do
      visit admin_custom_emojis_path

      2.times do
        select_location :local

        expect(page).to have_link(I18n.t('admin.accounts.location.local'), class: 'selected')
        expect_listed_emojis local_emoji
      end
    end

    it 'keeps the remote filter selected when clicked again' do
      visit admin_custom_emojis_path

      2.times do
        select_location :remote

        expect(page).to have_link(I18n.t('admin.accounts.location.remote'), class: 'selected')
        expect_listed_emojis remote_emoji, other_remote_emoji
      end
    end

    it 'preserves shortcode filtering when switching locations' do
      visit admin_custom_emojis_path(shortcode: 'wave')

      select_location :remote
      expect_listed_emojis remote_emoji

      select_location :local
      expect_listed_emojis local_emoji

      select_location :all
      expect_listed_emojis local_emoji, remote_emoji
    end

    it 'selects remote when searching by domain and preserves the domain on repeated clicks' do
      visit admin_custom_emojis_path
      fill_in I18n.t('admin.custom_emojis.by_domain'), with: 'example.org'
      click_on I18n.t('admin.accounts.search')

      expect(page).to have_link(I18n.t('admin.accounts.location.remote'), class: 'selected')
      expect_listed_emojis remote_emoji

      select_location :remote

      expect(page).to have_field('by_domain', with: 'example.org')
      expect_listed_emojis remote_emoji
    end

    it 'clears domain filtering when selecting all' do
      visit admin_custom_emojis_path(by_domain: 'example.org', shortcode: 'wave')

      select_location :all

      expect(find_field('by_domain').value).to be_blank
      expect_listed_emojis local_emoji, remote_emoji
    end

    it 'clears domain filtering when selecting local' do
      visit admin_custom_emojis_path(by_domain: 'example.org', shortcode: 'wave')

      select_location :local

      expect(page).to have_no_field('by_domain')
      expect_listed_emojis local_emoji
    end

    it 'submits each search field once and allows clearing the fields' do
      visit admin_custom_emojis_path(remote: '1', by_domain: 'example.org', shortcode: 'wave')

      within 'form[method="get"]' do
        expect(page)
          .to have_field('shortcode', count: 1)
          .and have_no_field('shortcode', type: 'hidden', visible: :all)
        expect(page)
          .to have_field('by_domain', count: 1)
          .and have_no_field('by_domain', type: 'hidden', visible: :all)
        fill_in 'shortcode', with: ''
        fill_in 'by_domain', with: ''
        click_on I18n.t('admin.accounts.search')
      end

      expect(page).to have_link(I18n.t('admin.accounts.location.remote'), class: 'selected')
      expect_listed_emojis remote_emoji, other_remote_emoji
    end

    def select_location(location)
      within '.filters' do
        click_on I18n.t("admin.accounts.location.#{location}")
      end
    end

    def expect_listed_emojis(*emojis)
      within '.batch-table__body' do
        expect(page).to have_css('.batch-table__row', count: emojis.size)
        emojis.each { |emoji| expect(page).to have_text(":#{emoji.shortcode}:") }
      end
    end
  end

  describe 'Creating a new emoji' do
    it 'saves a new emoji record with valid attributes' do
      visit new_admin_custom_emoji_path
      expect(page)
        .to have_text(I18n.t('admin.custom_emojis.title'))

      expect { submit_form }
        .to_not change(CustomEmoji, :count)
      expect(page)
        .to have_text(/errors below/)

      fill_in I18n.t('admin.custom_emojis.shortcode'),
              with: 'test'
      attach_file 'custom_emoji_image',
                  file_fixture('emojo.png')

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

        expect(page).to have_text(selection_error_text)
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
