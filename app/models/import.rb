# frozen_string_literal: true

class Import < ApplicationRecord
  FILE_TYPES = ['text/plain', 'text/csv'].freeze

  self.inheritance_column = false

  belongs_to :account, required: true

  enum type: [:following, :blocking, :muting]

  validates :type, presence: true

  has_attached_file :data, url: '/system/:hash.:extension', hash_secret: ENV['PAPERCLIP_SECRET']
  validates_attachment_content_type :data, content_type: FILE_TYPES
end
