# frozen_string_literal: true

require 'rails_helper'

describe 'Admin::Statuses' do
  let(:current_user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in current_user
  end

  describe 'Performing batch updates' do
    before do
      _status = Fabricate(:status, account: current_user.account)
      visit admin_account_statuses_path(account_id: current_user.account_id)
    end

    context 'without selecting any records' do
      it 'displays a notice about selection' do
        click_on button_for_report

        expect(page).to have_content(selection_error_text)
      end
    end

    def button_for_report
      I18n.t('admin.statuses.batch.report')
    end

    def selection_error_text
      I18n.t('admin.statuses.no_status_selected')
    end
  end
end
