# == Schema Information
#
# Table name: custom_templates
#
#  id         :bigint(8)        not null, primary key
#  content    :text             not null
#  disabled   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CustomTemplate < ApplicationRecord
  scope :alphabetic, -> { order(content: :asc) }

end
