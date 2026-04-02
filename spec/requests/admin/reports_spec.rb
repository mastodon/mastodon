# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Reports' do
  describe 'GET /admin/reports' do
    before do
      sign_in Fabricate(:admin_user)

      Fabricate.times(2, :report)
    end

    it 'returns success' do
      get admin_reports_path

      expect(response)
        .to have_http_status(200)
    end
  end

  describe 'GET /admin/reports/:id' do
    let(:report) { Fabricate(:report) }

    before do
      sign_in Fabricate(:admin_user)
    end

    shared_examples 'successful return' do
      it 'returns success' do
        get admin_report_path(report)

        expect(response)
          .to have_http_status(200)
      end
    end

    context 'with a simple report' do
      it_behaves_like 'successful return'
    end

    context 'with a reported status' do
      before do
        status = Fabricate(:status, account: report.target_account)
        report.update(status_ids: [status.id])
      end

      it_behaves_like 'successful return'
    end

    context 'with a reported collection', feature: :collections do
      before do
        report.collections << Fabricate(:collection, account: report.target_account)
      end

      it_behaves_like 'successful return'
    end

    context 'with both status and collection', feature: :collections do
      before do
        status = Fabricate(:status, account: report.target_account)
        report.update(status_ids: [status.id])
        report.collections << Fabricate(:collection, account: report.target_account)
      end

      it_behaves_like 'successful return'
    end
  end
end
