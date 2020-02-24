# frozen_string_literal: true
# == Schema Information
#
# Table name: imports
#
#  id                :bigint(8)        not null, primary key
#  type              :integer          not null
#  approved          :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  data_file_name    :string
#  data_content_type :string
#  data_file_size    :integer
#  data_updated_at   :datetime
#  account_id        :bigint(8)        not null
#  overwrite         :boolean          default(FALSE), not null
#

class Import < ApplicationRecord
  FILE_TYPES = %w(text/plain text/csv).freeze
  MODES = %i(merge overwrite).freeze

  self.inheritance_column = false

  belongs_to :account

  enum type: [:following, :blocking, :muting, :domain_blocking]

  validates :type, presence: true

  has_attached_file :data
  validates_attachment_content_type :data, content_type: FILE_TYPES
  validates_attachment_presence :data

  def mode
    overwrite? ? :overwrite : :merge
  end

  def mode=(str)
    self.overwrite = str.to_sym == :overwrite
  end
end
