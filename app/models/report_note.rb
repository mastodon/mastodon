# frozen_string_literal: true

# == Schema Information
#
# Table name: report_notes
#
#  id         :bigint(8)        not null, primary key
#  content    :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint(8)        not null
#  report_id  :bigint(8)        not null
#

class ReportNote < ApplicationRecord
  CONTENT_SIZE_LIMIT = 2_000

  belongs_to :account
  belongs_to :report, inverse_of: :notes, touch: true

  scope :chronological, -> { reorder(id: :asc) }

  validates :content, presence: true, length: { maximum: CONTENT_SIZE_LIMIT }
end
