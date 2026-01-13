# frozen_string_literal: true

class AnnualReport::CommonlyInteractedWithAccounts < AnnualReport::Source
  MINIMUM_INTERACTIONS = 1
  SET_SIZE = 40

  def generate
    {
      commonly_interacted_with_accounts: commonly_interacted_with_accounts.map do |(account_id, count)|
                                           {
                                             account_id: account_id.to_s,
                                             count: count,
                                           }
                                         end,
    }
  end

  private

  def commonly_interacted_with_accounts
    report_statuses.not_replying_to_account(@account).group(:in_reply_to_account_id).having(minimum_interaction_count).order(count_all: :desc).limit(SET_SIZE).count
  end

  def minimum_interaction_count
    Arel.star.count.gt(MINIMUM_INTERACTIONS)
  end
end
