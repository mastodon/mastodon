# frozen_string_literal: true

class StatusTrend < ApplicationRecord
  include RankedTrend

  belongs_to :status
  belongs_to :account

  scope :allowed, -> { joins('INNER JOIN (SELECT account_id, MAX(score) AS max_score FROM status_trends GROUP BY account_id) AS grouped_status_trends ON status_trends.account_id = grouped_status_trends.account_id AND status_trends.score = grouped_status_trends.max_score').where(allowed: true) }
end
