# frozen_string_literal: true

# == Schema Information
#
# Table name: status_trends
#
#  id         :bigint(8)        not null, primary key
#  status_id  :bigint(8)        not null
#  account_id :bigint(8)        not null
#  score      :float            default(0.0), not null
#  rank       :integer          default(0), not null
#  allowed    :boolean          default(FALSE), not null
#  language   :string
#

class StatusTrend < ApplicationRecord
  include RankedTrend

  belongs_to :status
  belongs_to :account

  scope :allowed, -> { where(allowed: true) }
  scope :not_allowed, -> { where(allowed: false) }
  scope :with_account_constraint, -> { joins(account_constraint_joins) }

  def self.account_constraint_joins
    <<~SQL.squish
      INNER JOIN (#{account_grouped_max_score})
      AS grouped_status_trends
      ON status_trends.account_id = grouped_status_trends.account_id
        AND status_trends.score = grouped_status_trends.max_score
    SQL
  end

  def self.account_grouped_max_score
    select(:account_id, arel_table[:score].maximum.as('max_score'))
      .group(:account_id)
      .to_sql
  end
end
