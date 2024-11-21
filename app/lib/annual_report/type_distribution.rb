# frozen_string_literal: true

class AnnualReport::TypeDistribution < AnnualReport::Source
  def generate
    {
      type_distribution: {
        total: report_statuses.count,
        reblogs: report_statuses.where.not(reblog_of_id: nil).count,
        replies: report_statuses.where.not(in_reply_to_id: nil).where.not(in_reply_to_account_id: @account.id).count,
        standalone: report_statuses.without_replies.without_reblogs.count,
      },
    }
  end
end
