# frozen_string_literal: true
# == Schema Information
#
# Table name: backups
#
#  id                :bigint(8)        not null, primary key
#  user_id           :bigint(8)
#  dump_file_name    :string
#  dump_content_type :string
#  dump_updated_at   :datetime
#  processed         :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  dump_file_size    :bigint(8)
#

class Backup < ApplicationRecord
  belongs_to :user, inverse_of: :backups

  has_attached_file :dump
  validates_attachment_content_type :dump, content_type: /\Aapplication/
end
