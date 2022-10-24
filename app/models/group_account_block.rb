# == Schema Information
#
# Table name: group_account_blocks
#
#  id         :bigint(8)        not null, primary key
#  account_id :bigint(8)        not null
#  group_id   :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class GroupAccountBlock < ApplicationRecord
  include Paginable

  belongs_to :group
  belongs_to :account
end
