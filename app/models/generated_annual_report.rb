# frozen_string_literal: true

# == Schema Information
#
# Table name: generated_annual_reports
#
#  id             :bigint(8)        not null, primary key
#  account_id     :bigint(8)        not null
#  year           :integer          not null
#  data           :jsonb            not null
#  schema_version :integer          not null
#  viewed_at      :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class GeneratedAnnualReport < ApplicationRecord
  belongs_to :account

  scope :pending, -> { where(viewed_at: nil) }

  def viewed?
    viewed_at.present?
  end

  def view!
    update!(viewed_at: Time.now.utc)
  end

  def account_ids
    data['most_reblogged_accounts'].pluck('account_id') + data['commonly_interacted_with_accounts'].pluck('account_id')
  end

  def status_ids
    data['top_statuses'].values
  end
end
