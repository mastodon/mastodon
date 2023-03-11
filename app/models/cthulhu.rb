# == Schema Information
#
# Table name: cthulhus
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  story      :text
#
class Cthulhu < ApplicationRecord
end
