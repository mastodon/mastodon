# frozen_string_literal: true
# == Schema Information
#
# Table name: deletion_schedules
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)
#  delay      :integer          default(604800), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DeletionSchedule < ApplicationRecord
  belongs_to :user

  validates :delay, presence: true, numericality: { only_integer: true, greater_than: 7.days.seconds }
end
