# frozen_string_literal: true

class AnnualReport::CommonlyInteractedWithAccounts < AnnualReport::Source
  SET_SIZE = 40
  MINIMUM_INTERACTIONS = 1

  def generate
    {
      commonly_interacted_with_accounts: account_map,
    }
  end

  private

  def account_map
    commonly_interacted_with_accounts.map do |account_id, count|
      {
        account_id: account_id.to_s,
        count: count,
      }
    end
  end

  def commonly_interacted_with_accounts
    report_statuses
      .without_replies_to(@account)
      .group(:in_reply_to_account_id)
      .having(Arel.star.count.gt(MINIMUM_INTERACTIONS))
      .limit(SET_SIZE)
      .order(total: :desc)
      .pluck(:in_reply_to_account_id, Arel.star.count.as('total'))
  end
end
