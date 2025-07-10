# frozen_string_literal: true

class AnnualReport::TypeDistribution < AnnualReport::Source
  def generate
    {
      type_distribution: {
        total: report_statuses.count,
        reblogs: report_statuses.only_reblogs.count,
        replies: report_statuses.only_replies.not_replying_to_account(@account).count,
        standalone: report_statuses.without_replies.without_reblogs.count,
      },
    }
  end
end
