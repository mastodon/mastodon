# frozen_string_literal: true

class Import < ApplicationRecord
  self.inheritance_column = false

  enum type: [:following, :blocking, :muting]

  belongs_to :account

  FILE_TYPES = ['text/plain', 'text/csv'].freeze

  has_attached_file :data, url: '/system/:hash.:extension', hash_secret: ENV['PAPERCLIP_SECRET']
  validates_attachment_content_type :data, content_type: FILE_TYPES
end
