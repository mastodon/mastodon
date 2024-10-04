# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Reports', :js do
  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in user
  end

  describe 'Processing a report' do
    let(:report) { Fabricate :report }

    it 'marks a report resolved from the show page actions area' do
      visit admin_report_path(report)

      expect { resolve_report }
        .to change { report.reload.action_taken_at }.to(be_present).from(nil)
    end

    def resolve_report
      within '.report-actions' do
        click_on I18n.t('admin.reports.mark_as_resolved')
      end
    end
  end
end
