# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'report interface', :attachment_processing do
  include ProfileStories

  let(:email)               { 'admin@example.com' }
  let(:password)            { 'password' }
  let(:confirmed_at)        { Time.zone.now }
  let(:finished_onboarding) { true }

  let(:reported_account) { Fabricate(:account) }
  let(:reported_status) { Fabricate(:status, account: reported_account) }
  let(:media_attachment) { Fabricate(:media_attachment, account: reported_account, status: reported_status, file: attachment_fixture('attachment.jpg')) }
  let!(:report) { Fabricate(:report, target_account: reported_account, status_ids: [media_attachment.status.id]) }

  before do
    as_a_logged_in_admin
    visit admin_report_path(report)
  end

  context 'with collection reports', feature: :collections do
    let(:collection) { Fabricate(:collection, account: reported_account) }
    let(:collection2) { Fabricate(:collection, account: reported_account) }
    let(:collection_report) { Fabricate(:collection_report, collection: collection, report: report) }
    let(:collection_report2) { Fabricate(:collection_report, collection: collection, report: report) }

    before do
      collection_report
      collection_report_2
    end

    it 'displays the report interface with collection reports' do
      visit admin_report_path(report)

      expect(page).to have_text('Collections (2)')
      expect(page).to have_text('Add more to report').twice
      expect(page).to have_link(I18n.t('admin.reports.add_to_report'))
    end
  end

  it 'displays the report interface, including the javascript bits', :js do
    # The report category selector React component is properly rendered
    expect(page).to have_css('.report-reason-selector')

    # The media React component is properly rendered
    page.scroll_to(page.find('.batch-table__row'))
    expect(page).to have_css('.spoiler-button__overlay__label')
  end

  it 'marks a report resolved from the show page actions area' do
    visit admin_report_path(report)

    expect { resolve_report }
      .to change { report.reload.action_taken_at }.to(be_present).from(nil)
  end

  def resolve_report
    within '.report-actions' do
      click_on I18n.t('admin.reports.mark_as_resolved')
    end
    expect(page)
      .to have_text(I18n.t('admin.reports.resolved_msg'))
  end
end
