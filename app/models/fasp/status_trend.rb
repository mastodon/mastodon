# frozen_string_literal: true

# == Schema Information
#
# Table name: fasp_status_trends
#
#  id               :bigint(8)        not null, primary key
#  allowed          :boolean          default(FALSE), not null
#  language         :string           not null
#  rank             :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  fasp_provider_id :bigint(8)        not null
#  status_id        :bigint(8)        not null
#
class Fasp::StatusTrend < ApplicationRecord
  belongs_to :status
  belongs_to :fasp_provider, class_name: 'Fasp::Provider'

  scope :allowed, -> { where(allowed: true) }
  scope :in_language, ->(language) { where(language:) }
  scope :ranked, -> { order(rank: :desc) }

  def self.statuses(language:, filtered_for: nil)
    scope = Status.joins(:fasp_status_trends)
                  .merge(allowed)
                  .merge(ranked)
    scope = scope.not_excluded_by_account(filtered_for).not_domain_blocked_by_account(filtered_for) if filtered_for
    scope = scope.merge(in_language(language)) if language
    scope
  end
end
