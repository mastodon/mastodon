# frozen_string_literal: true
# == Schema Information
#
# Table name: report_notes
#
#  id         :bigint(8)        not null, primary key
#  content    :text             not null
#  report_id  :bigint(8)        not null
#  account_id :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReportNote < ApplicationRecord
  belongs_to :account
  belongs_to :report, inverse_of: :notes, touch: true

  scope :latest, -> { reorder(created_at: :desc) }

  validates :content, presence: true, length: { maximum: 500 }
end
