# frozen_string_literal: true

# == Schema Information
#
# Table name: rule_translations
#
#  id         :bigint(8)        not null, primary key
#  hint       :text             default(""), not null
#  language   :string           not null
#  text       :text             default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  rule_id    :bigint(8)        not null
#
class RuleTranslation < ApplicationRecord
  belongs_to :rule

  validates :language, uniqueness: { scope: :rule_id }
end
