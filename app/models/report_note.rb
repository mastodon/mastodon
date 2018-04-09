# frozen_string_literal: true
# == Schema Information
#
# Table name: report_notes
#
#  id         :integer          not null, primary key
#  content    :text             not null
#  report_id  :integer          not null
#  account_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReportNote < ApplicationRecord
  belongs_to :account
  belongs_to :report, inverse_of: :notes

  scope :latest, -> { reorder('created_at ASC') }

  validates :content, presence: true, length: { maximum: 500 }
end
