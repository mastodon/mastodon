# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Export page' do
  let(:user) { Fabricate :user }

  before { sign_in user }

  describe 'Viewing the export page' do
    context 'when signed in' do
      it 'shows the export page', :aggregate_failures do
        visit settings_export_path

        expect(page)
          .to have_content(takeout_summary)
          .and have_private_cache_control
      end
    end
  end

  describe 'Creating a new archive' do
    it 'queues a worker and redirects' do
      visit settings_export_path

      expect { request_archive }
        .to change(BackupWorker.jobs, :size).by(1)
      expect(page)
        .to have_content(takeout_summary)
    end

    def request_archive
      click_on I18n.t('exports.archive_takeout.request')
    end
  end

  def takeout_summary
    I18n.t('settings.export')
  end
end
