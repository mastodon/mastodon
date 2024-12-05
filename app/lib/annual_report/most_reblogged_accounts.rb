# frozen_string_literal: true

class AnnualReport::MostRebloggedAccounts < AnnualReport::Source
  SET_SIZE = 10

  def generate
    {
      most_reblogged_accounts: most_reblogged_accounts.map do |(account_id, count)|
                                 {
                                   account_id: account_id,
                                   count: count,
                                 }
                               end,
    }
  end

  private

  def most_reblogged_accounts
    report_statuses.where.not(reblog_of_id: nil).joins(reblog: :account).group('accounts.id').having('count(*) > 1').order(total: :desc).limit(SET_SIZE).pluck(Arel.sql('accounts.id, count(*) as total'))
  end
end
