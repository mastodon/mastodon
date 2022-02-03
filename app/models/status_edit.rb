# frozen_string_literal: true
# == Schema Information
#
# Table name: status_edits
#
#  id                        :bigint(8)        not null, primary key
#  status_id                 :bigint(8)        not null
#  account_id                :bigint(8)
#  text                      :text             default(""), not null
#  spoiler_text              :text             default(""), not null
#  media_attachments_changed :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class StatusEdit < ApplicationRecord
  belongs_to :status
  belongs_to :account, optional: true

  default_scope { order(id: :asc) }

  delegate :local?, to: :status
end
