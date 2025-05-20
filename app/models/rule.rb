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

  def move!(offset)
    rules = Rule.ordered.to_a
    position = rules.index(self)

    rules.delete_at(position)
    rules.insert(position + offset, self)

    transaction do
      rules.each.with_index do |rule, index|
        rule.update!(priority: index)
      end
    end
  end
end
