# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'report interface', :attachment_processing, :js, :streaming do
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

  it 'displays the report interface, including the javascript bits' do
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
  end
end
