# frozen_string_literal: true

module AccountAvatar
  extend ActiveSupport::Concern
  IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze

  class_methods do
    def avatar_styles(file)
      styles = { original: '120x120#' }
      styles[:static] = { format: 'png' } if file.content_type == 'image/gif'
      styles
    end
    private :avatar_styles
  end

  included do
    # Avatar upload
    has_attached_file :avatar, styles: ->(f) { avatar_styles(f) }, convert_options: { all: '-quality 80 -strip' }
    validates_attachment_content_type :avatar, content_type: IMAGE_MIME_TYPES
    validates_attachment_size :avatar, less_than: 2.megabytes

    def avatar_original_url
      avatar.url(:original)
    end

    def avatar_static_url
      avatar_content_type == 'image/gif' ? avatar.url(:static) : avatar_original_url
    end

    def avatar_remote_url=(url)
      parsed_url = Addressable::URI.parse(url).normalize

      return if !%w(http https).include?(parsed_url.scheme) || parsed_url.host.empty? || self[:avatar_remote_url] == url

      self.avatar              = URI.parse(parsed_url.to_s)
      self[:avatar_remote_url] = url
    rescue OpenURI::HTTPError => e
      Rails.logger.debug "Error fetching remote avatar: #{e}"
    end
  end
end
