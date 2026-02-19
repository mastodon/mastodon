# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Trends::Statuses' do
  let(:current_user) { Fabricate(:admin_user) }

  before { sign_in current_user }

  describe 'Performing batch updates' do
    context 'without selecting any records' do
      it 'displays a notice about selection' do
        visit admin_trends_statuses_path
        expect(page)
          .to have_title(I18n.t('admin.trends.statuses.title'))

        click_on button_for_allow

        expect(page)
          .to have_content(selection_error_text)
      end
    end

    context 'with statuses that are not trendable' do
      let!(:status_trend) { Fabricate :status_trend, status: Fabricate(:status, trendable: false) }

      it 'allows the statuses' do
        visit admin_trends_statuses_path

        check_item

        expect { click_on button_for_allow }
          .to change { status_trend.status.reload.trendable? }.from(false).to(true)
      end
    end

    context 'with statuses whose accounts are not trendable' do
      let!(:status_trend) { Fabricate :status_trend, status: Fabricate(:status, account: Fabricate(:account, trendable: false)) }

      it 'allows the accounts of the statuses' do
        visit admin_trends_statuses_path

        check_item

        expect { click_on button_for_allow_accounts }
          .to change { status_trend.status.account.reload.trendable? }.from(false).to(true)
      end
    end

    context 'with statuses that are trendable' do
      let!(:status_trend) { Fabricate :status_trend, status: Fabricate(:status, trendable: true) }

      it 'disallows the statuses' do
        visit admin_trends_statuses_path

        check_item

        expect { click_on button_for_disallow }
          .to change { status_trend.status.reload.trendable? }.from(true).to(false)
      end
    end

    context 'with statuses whose accounts are trendable' do
      let!(:status_trend) { Fabricate :status_trend, status: Fabricate(:status, account: Fabricate(:account, trendable: true)) }

      it 'disallows the statuses' do
        visit admin_trends_statuses_path

        check_item

        expect { click_on button_for_disallow_accounts }
          .to change { status_trend.status.reload.trendable? }.from(true).to(false)
      end
    end

    def check_item
      within '.batch-table__row' do
        find('input[type=checkbox]').check
      end
    end

    def button_for_allow
      I18n.t('admin.trends.statuses.allow')
    end

    def button_for_allow_accounts
      I18n.t('admin.trends.statuses.allow_account')
    end

    def button_for_disallow
      I18n.t('admin.trends.statuses.disallow')
    end

    def button_for_disallow_accounts
      I18n.t('admin.trends.statuses.disallow_account')
    end

    def selection_error_text
      I18n.t('admin.trends.statuses.no_status_selected')
    end
  end
end
