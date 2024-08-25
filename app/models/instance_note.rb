# frozen_string_literal: true

# == Schema Information
#
# Table name: instance_notes
#
#  id         :bigint(8)        not null, primary key
#  domain     :string
#  account_id :bigint(8)
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class InstanceNote < ApplicationRecord
  include DomainNormalizable
  include DomainMaterializable

  CONTENT_SIZE_LIMIT = 2_000

  belongs_to :account
  belongs_to :instance, inverse_of: :notes, foreign_key: :domain, primary_key: :domain, optional: true

  scope :latest, -> { reorder(id: :asc) }

  validates :content, presence: true, length: { maximum: CONTENT_SIZE_LIMIT }
  validates :domain, presence: true, domain: true
end
