# frozen_string_literal: true

# == Schema Information
#
# Table name: annual_report_statuses_per_account_counts
#
#  id             :bigint(8)        not null, primary key
#  year           :integer          not null
#  account_id     :bigint(8)        not null
#  statuses_count :bigint(8)        not null
#

class AnnualReport::StatusesPerAccountCount < ApplicationRecord
  # This table facilitates percentile calculations
end
