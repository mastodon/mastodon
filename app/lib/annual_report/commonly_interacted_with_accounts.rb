# frozen_string_literal: true

class AnnualReport::CommonlyInteractedWithAccounts < AnnualReport::Source
  SET_SIZE = 40

  def generate
    {
      commonly_interacted_with_accounts: commonly_interacted_with_accounts.map do |(account_id, count)|
                                           {
                                             account_id: account_id,
                                             count: count,
                                           }
                                         end,
    }
  end

  private

  def commonly_interacted_with_accounts
    report_statuses.where.not(in_reply_to_account_id: @account.id).group(:in_reply_to_account_id).having('count(*) > 1').order(total: :desc).limit(SET_SIZE).pluck(Arel.sql('in_reply_to_account_id, count(*) AS total'))
  end
end
