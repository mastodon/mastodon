# frozen_string_literal: true

# == Schema Information
#
# Table name: rules
#
#  id         :bigint(8)        not null, primary key
#  priority   :integer          default(0), not null
#  deleted_at :datetime
#  text       :text             default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  hint       :text             default(""), not null
#
class Rule < ApplicationRecord
  include Discard::Model

  TEXT_SIZE_LIMIT = 300

  self.discard_column = :deleted_at

  validates :text, presence: true, length: { maximum: TEXT_SIZE_LIMIT }

  scope :ordered, -> { kept.order(priority: :asc, id: :asc) }
end
