# frozen_string_literal: true

# == Schema Information
#
# Table name: collection_reports
#
#  id            :bigint(8)        not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  collection_id :bigint(8)        not null
#  report_id     :bigint(8)        not null
#
class CollectionReport < ApplicationRecord
  belongs_to :collection
  belongs_to :report
end
