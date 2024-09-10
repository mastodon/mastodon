# frozen_string_literal: true

class AnnualReport::TypeDistribution < AnnualReport::Source
  def generate
    {
      type_distribution: {
        total: report_statuses.count,
        reblogs: reblog_statuses.count,
        replies: replied_statuses.count,
        standalone: standalone_statuses.count,
      },
    }
  end

  private

  def reblog_statuses
    report_statuses.with_reblogs
  end

  def replied_statuses
    report_statuses.with_replies.without_replies_to(@account)
  end

  def standalone_statuses
    report_statuses.without_replies.without_reblogs
  end
end
