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

  self.discard_column = :deleted_at

  validates :text, presence: true, length: { maximum: 300 }

  scope :ordered, -> { kept.order(priority: :asc, id: :asc) }
end
