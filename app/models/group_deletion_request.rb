# frozen_string_literal: true

# == Schema Information
#
# Table name: group_deletion_requests
#
#  id         :bigint(8)        not null, primary key
#  group_id   :bigint(8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class GroupDeletionRequest < ApplicationRecord
  DELAY_TO_DELETION = 30.days.freeze

  belongs_to :group

  def due_at
    created_at + DELAY_TO_DELETION
  end
end
