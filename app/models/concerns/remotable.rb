# frozen_string_literal: true

module Remotable
  extend ActiveSupport::Concern

  class_methods do
    def remotable_attachment(attachment_name, limit, suppress_errors: true)
      attribute_name  = "#{attachment_name}_remote_url".to_sym
      method_name     = "#{attribute_name}=".to_sym
      alt_method_name = "reset_#{attachment_name}!".to_sym

      define_method method_name do |url|
        return if url.blank?

        begin
          parsed_url = Addressable::URI.parse(url).normalize
        rescue Addressable::URI::InvalidURIError
          return
        end

        return if !%w(http https).include?(parsed_url.scheme) || parsed_url.host.blank? || self[attribute_name] == url

        begin
          Request.new(:get, url).perform do |response|
            raise Mastodon::UnexpectedResponseError, response unless (200...300).cover?(response.code)

            content_type = parse_content_type(response.headers.get('content-type').last)
            extname      = detect_extname_from_content_type(content_type)

            if extname.nil?
              disposition = response.headers.get('content-disposition').last
              matches     = disposition&.match(/filename="([^"]*)"/)
              filename    = matches.nil? ? parsed_url.path.split('/').last : matches[1]
              extname     = filename.nil? ? '' : File.extname(filename)
            end

            basename = SecureRandom.hex(8)

            send("#{attachment_name}=", StringIO.new(response.body_with_limit(limit)))
            send("#{attachment_name}_file_name=", basename + extname)

            self[attribute_name] = url if has_attribute?(attribute_name)
          end
        rescue Mastodon::UnexpectedResponseError, HTTP::TimeoutError, HTTP::ConnectionError, OpenSSL::SSL::SSLError => e
          Rails.logger.debug "Error fetching remote #{attachment_name}: #{e}"
          raise e unless suppress_errors
        rescue Paperclip::Errors::NotIdentifiedByImageMagickError, Addressable::URI::InvalidURIError, Mastodon::HostValidationError, Mastodon::LengthValidationError, Paperclip::Error, Mastodon::DimensionsValidationError => e
          Rails.logger.debug "Error fetching remote #{attachment_name}: #{e}"
          nil
        end
      end

      define_method alt_method_name do
        url = self[attribute_name]

        return if url.blank?

        self[attribute_name] = ''
        send(method_name, url)
      end
    end
  end

  private

  def detect_extname_from_content_type(content_type)
    return if content_type.nil?

    type = MIME::Types[content_type].first

    return if type.nil?

    extname = type.extensions.first

    return if extname.nil?

    ".#{extname}"
  end

  def parse_content_type(content_type)
    return if content_type.nil?

    content_type.split(/\s*;\s*/).first
  end
end
