# frozen_string_literal: true
# == Schema Information
#
# Table name: backups
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  dump_file_name    :string
#  dump_content_type :string
#  dump_file_size    :integer
#  dump_updated_at   :datetime
#  processed         :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Backup < ApplicationRecord
  belongs_to :user, inverse_of: :backups

  has_attached_file :dump
  do_not_validate_attachment_file_type :dump
end
