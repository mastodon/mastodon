# frozen_string_literal: true

class AnnualReport::TypeDistribution < AnnualReport::Source
  def generate
    {
      type_distribution: {
        total: report_statuses.count,
        reblogs: report_statuses.only_reblogs.count,
        replies: report_statuses.where.not(in_reply_to_id: nil).not_replying_to_account(@account).count,
        standalone: report_statuses.without_replies.without_reblogs.count,
      },
    }
  end
end
