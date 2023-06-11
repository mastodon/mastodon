# frozen_string_literal: true

# == Schema Information
#
# Table name: status_trend_highlights
#
#  id         :bigint(8)        not null, primary key
#  period     :datetime         not null
#  status_id  :bigint(8)        not null
#  account_id :bigint(8)        not null
#  score      :float            default(0.0), not null
#  language   :string
#

class StatusTrendHighlight < ApplicationRecord
  belongs_to :status
  belongs_to :account

  def self.weekly(account)
    Status.joins(:trend_highlight, :account)
          .merge(Account.discoverable)
          .where(arel_table[:period].gteq(1.week.ago))
          .not_excluded_by_account(account)
          .not_domain_blocked_by_account(account)
          .reorder(Arel::Nodes::Case.new.when(arel_table[:language].in(account.chosen_languages || account.user_locale)).then(1).else(0).desc, score: :desc)
  end
end
