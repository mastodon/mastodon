# frozen_string_literal: true
# == Schema Information
#
# Table name: site_uploads
#
#  id                :integer          not null, primary key
#  var               :string           default(""), not null
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#  meta              :json
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class SiteUpload < ApplicationRecord
  has_attached_file :file

  validates_attachment_content_type :file, content_type: /\Aimage\/.*\z/
  validates :var, presence: true, uniqueness: true

  before_save :set_meta
  after_commit :clear_cache

  def cache_key
    "site_uploads/#{var}"
  end

  private

  def set_meta
    tempfile = file.queued_for_write[:original]

    return if tempfile.nil?

    geometry  = Paperclip::Geometry.from_file(tempfile)
    self.meta = { width: geometry.width.to_i, height: geometry.height.to_i }
  end

  def clear_cache
    Rails.cache.delete(cache_key)
  end
end
