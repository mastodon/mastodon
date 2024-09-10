# frozen_string_literal: true

class AnnualReport::MostRebloggedAccounts < AnnualReport::Source
  SET_SIZE = 10
  MINIMUM_COUNT = 1

  def generate
    {
      most_reblogged_accounts: account_map,
    }
  end

  private

  def account_map
    most_reblogged_accounts.map do |account_id, count|
      {
        account_id: account_id.to_s,
        count: count,
      }
    end
  end

  def most_reblogged_accounts
    report_statuses
      .with_reblogs
      .group(Account.arel_table[:id])
      .having(Arel.star.count.gt(MINIMUM_COUNT))
      .joins(reblog: :account)
      .limit(SET_SIZE)
      .order(total: :desc)
      .pluck(Account.arel_table[:id], Arel.star.count.as('total'))
  end
end
