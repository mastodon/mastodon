# == Schema Information
#
# Table name: keyword_mutes
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  keyword    :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class KeywordMute < ApplicationRecord
end
