# frozen_string_literal: true

class Backup < ApplicationRecord
  belongs_to :user, inverse_of: :backups

  has_attached_file :dump, s3_permissions: ->(*) { ENV['S3_PERMISSION'] == '' ? nil : 'private' }
  validates_attachment_content_type :dump, content_type: /\Aapplication/
end
