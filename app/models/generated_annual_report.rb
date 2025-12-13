# frozen_string_literal: true

# == Schema Information
#
# Table name: generated_annual_reports
#
#  id             :bigint(8)        not null, primary key
#  data           :jsonb            not null
#  schema_version :integer          not null
#  share_key      :string
#  viewed_at      :datetime
#  year           :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  account_id     :bigint(8)        not null
#

class GeneratedAnnualReport < ApplicationRecord
  belongs_to :account

  scope :pending, -> { where(viewed_at: nil) }

  def viewed?
    viewed_at.present?
  end

  def view!
    touch(:viewed_at)
  end

  def account_ids
    case schema_version
    when 1
      data['most_reblogged_accounts'].pluck('account_id') + data['commonly_interacted_with_accounts'].pluck('account_id')
    when 2
      [account_id]
    end
  end

  def status_ids
    data['top_statuses'].values
  end
end
