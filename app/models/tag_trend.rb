# frozen_string_literal: true

# == Schema Information
#
# Table name: tag_trends
#
#  id       :bigint(8)        not null, primary key
#  allowed  :boolean          default(FALSE), not null
#  language :string           default(""), not null
#  rank     :integer          default(0), not null
#  score    :float            default(0.0), not null
#  tag_id   :bigint(8)        not null
#
class TagTrend < ApplicationRecord
  include RankedTrend

  belongs_to :tag

  scope :allowed, -> { where(allowed: true) }
  scope :not_allowed, -> { where(allowed: false) }
end
