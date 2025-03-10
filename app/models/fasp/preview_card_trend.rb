# frozen_string_literal: true

# == Schema Information
#
# Table name: fasp_preview_card_trends
#
#  id               :bigint(8)        not null, primary key
#  allowed          :boolean          default(FALSE), not null
#  language         :string           not null
#  rank             :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  fasp_provider_id :bigint(8)        not null
#  preview_card_id  :bigint(8)        not null
#
class Fasp::PreviewCardTrend < ApplicationRecord
  belongs_to :preview_card
  belongs_to :fasp_provider, class_name: 'Fasp::Provider'

  scope :allowed, -> { where(allowed: true) }
  scope :in_language, ->(language) { where(language:) }
  scope :ranked, -> { order(rank: :desc) }

  def self.preview_cards(language:)
    scope = PreviewCard.joins(:fasp_preview_card_trends)
                       .merge(allowed)
                       .merge(ranked)
    scope = scope.merge(in_language(language)) if language
    scope
  end
end
