# frozen_string_literal: true

# == Schema Information
#
# Table name: tombstones
#
#  id         :bigint(8)        not null, primary key
#  account_id :bigint(8)
#  uri        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Tombstone < ApplicationRecord
  belongs_to :account
end
