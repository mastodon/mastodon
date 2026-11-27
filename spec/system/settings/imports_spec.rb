# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Imports' do
  let(:user) { Fabricate(:user) }

  before { sign_in user }

  describe 'Viewing recent imports' do
    let!(:import) { Fabricate(:bulk_import, account: user.account) }
    let!(:other_import) { Fabricate(:bulk_import) }

    it 'shows only the user imports with private cache headers' do
      visit settings_imports_path

      expect(page)
        .to have_title(I18n.t('settings.import'))
        .and have_css("#bulk_import_#{import.id}")
        .and have_no_css("#bulk_import_#{other_import.id}")
        .and have_private_cache_control
    end
  end

  describe 'Uploading an import' do
    shared_examples 'successful import' do |type, file|
      it "creates an unconfirmed #{type} import and shows the review page" do
        visit settings_imports_path

        select I18n.t("imports.types.#{type}"), from: 'form_import_type'
        choose "form_import_mode_#{import_mode}"
        attach_file 'form_import_data', file_fixture(file)

        expect { click_on I18n.t('imports.upload') }
          .to change { user.account.bulk_imports.pluck(:state, :type, :overwrite) }
          .from([])
          .to([['unconfirmed', type, import_mode == 'overwrite']])

        expect(page)
          .to have_current_path(settings_import_path(user.account.bulk_imports.first))
          .and have_link(I18n.t('generic.confirm'))
          .and have_link(I18n.t('generic.cancel'))
      end
    end

    %w(merge overwrite).each do |mode|
      context "with #{mode} mode" do
        let(:import_mode) { mode }

        it_behaves_like 'successful import', 'following', 'imports.txt'
        it_behaves_like 'successful import', 'blocking', 'imports.txt'
        it_behaves_like 'successful import', 'muting', 'imports.txt'
        it_behaves_like 'successful import', 'domain_blocking', 'domain_blocks.csv'
        it_behaves_like 'successful import', 'bookmarks', 'bookmark-imports.txt'
      end
    end

    context 'with custom filters' do
      let(:import_mode) { 'merge' }

      it_behaves_like 'successful import', 'custom_filters', 'custom_filters.json'
    end
  end

  describe 'Confirming an import' do
    let!(:bulk_import) { Fabricate(:bulk_import, account: user.account, state: :unconfirmed) }

    it 'schedules the import and returns to the imports page' do
      visit settings_imports_path
      click_on I18n.t('imports.states.unconfirmed')

      expect(page)
        .to have_current_path(settings_import_path(bulk_import))
        .and have_title(I18n.t("imports.titles.#{bulk_import.type}"))

      expect { click_on I18n.t('generic.confirm') }
        .to change { bulk_import.reload.state }.from('unconfirmed').to('scheduled')

      expect(BulkImportWorker)
        .to have_enqueued_sidekiq_job(bulk_import.id)
      expect(page)
        .to have_current_path(settings_imports_path)
        .and have_text(I18n.t('imports.success'))
    end
  end

  describe 'Cancelling an import' do
    let!(:bulk_import) { Fabricate(:bulk_import, account: user.account, state: :unconfirmed) }

    it 'deletes the unconfirmed import and returns to the imports page' do
      visit settings_imports_path
      click_on I18n.t('imports.states.unconfirmed')

      expect { click_on I18n.t('generic.cancel') }
        .to change { BulkImport.exists?(bulk_import.id) }.from(true).to(false)

      expect(page)
        .to have_current_path(settings_imports_path)
        .and have_no_css("#bulk_import_#{bulk_import.id}")
    end
  end
end
