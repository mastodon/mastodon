# frozen_string_literal: true

# == Schema Information
#
# Table name: tag_trends
#
#  id       :bigint(8)        not null, primary key
#  tag_id   :bigint(8)        not null
#  score    :float            default(0.0), not null
#  rank     :integer          default(0), not null
#  allowed  :boolean          default(FALSE), not null
#  language :string
#
class TagTrend < ApplicationRecord
  include RankedTrend

  belongs_to :tag

  scope :allowed, -> { where(allowed: true) }
  scope :not_allowed, -> { where(allowed: false) }
end
