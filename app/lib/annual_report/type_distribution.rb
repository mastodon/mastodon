# frozen_string_literal: true

class AnnualReport::TypeDistribution < AnnualReport::Source
  def generate
    {
      type_distribution: {
        total: base_scope.count,
        reblogs: base_scope.where.not(reblog_of_id: nil).count,
        replies: base_scope.where.not(in_reply_to_id: nil).where.not(in_reply_to_account_id: @account.id).count,
        standalone: base_scope.without_replies.without_reblogs.count,
      },
    }
  end

  private

  def base_scope
    @account.statuses.where(id: year_as_snowflake_range)
  end
end
