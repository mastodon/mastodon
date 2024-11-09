# frozen_string_literal: true

module Admin::ReportsHelper
  def admin_reports_category_options
    [
      [t('admin.reports.categories.spam'), 'spam'],
      [t('admin.reports.categories.legal'), 'legal'],
      [t('admin.reports.categories.violation'), 'violation'],
      [t('admin.reports.categories.other'), 'other'],
    ]
  end

  def admin_reports_status_options
    [
      [t('admin.reports.unresolved'), 'unresolved'],
      [t('admin.reports.resolved'), 'resolved'],
    ]
  end

  def admin_reports_target_origin_options
    [
      [t('admin.accounts.location.local'), 'local'],
      [t('admin.accounts.location.remote'), 'remote'],
    ]
  end
end
