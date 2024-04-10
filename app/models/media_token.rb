# == Schema Information
#
# Table name: media_tokens
#
#  id                  :bigint(8)        not null, primary key
#  media_attachment_id :bigint(8)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class MediaToken < ApplicationRecord
  belongs_to :media_attachment
end
