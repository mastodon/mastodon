# frozen_string_literal: true

class Admin::ServerCheck::MediaPrivacyRunner
  include Admin::ServerCheck::Runner
  include RoutingHelper

  def authorized?(user)
    user.can?(:view_devops)
  end

  def run
    Rails.configuration.x.use_s3 ? run_s3 : run_default
  end

  private

  def run_default
    full_url = full_asset_url(media_attachment.file.url(:original, false))

    # Check if we can list the uploaded file. If true, that's an error
    directory_url = Addressable::URI.parse(full_url)
    directory_url.query = nil
    filename = directory_url.path.gsub(%r{.*/}, '')
    directory_url.path = directory_url.path.gsub(%r{/[^/]+\Z}, '/')

    res = Request.new(:get, directory_url, allow_local: true).perform do |res|
      if res.truncated_body&.include?(filename)
        reason = use_storage? ? :upload_check_privacy_error_object_storage : :upload_check_privacy_error
        pending(data: { reason: })
      end
    end

    res || ok
  rescue => e
    error(data: { error: e.message })
  end

  def run_s3
    urls_to_check = []
    paperclip_options = Paperclip::Attachment.default_options
    s3_protocol = paperclip_options[:s3_protocol]
    s3_host_alias = paperclip_options[:s3_host_alias]
    s3_host_name  = paperclip_options[:s3_host_name]
    bucket_name = paperclip_options.dig(:s3_credentials, :bucket)

    res = nil
    urls_to_check << "#{s3_protocol}://#{s3_host_alias}/" if s3_host_alias.present?
    urls_to_check << "#{s3_protocol}://#{s3_host_name}/#{bucket_name}/"
    urls_to_check.uniq.each do |full_url|
      res = check_s3_listing!(full_url)
      break if res.present?
    end

    res || ok
  rescue => e
    error(data: { error: e.message })
  end

  def check_s3_listing!(full_url)
    bucket_url = Addressable::URI.parse(full_url)
    bucket_url.path = bucket_url.path.delete_suffix(media_attachment.file.path(:original))
    bucket_url.query = "max-keys=1&x-random=#{SecureRandom.hex(10)}"
    Request.new(:get, bucket_url, allow_local: true).perform do |res|
      pending(data: { reason: :upload_check_privacy_error_object_storage }) if res.truncated_body&.include?('ListBucketResult')
    end
  end

  def media_attachment
    @media_attachment ||= begin
      attachment = Account.representative.media_attachments.take
      if attachment.present?
        attachment.touch
        attachment
      else
        create_test_attachment!
      end
    end
  end

  def create_test_attachment!
    Tempfile.create(%w(test-upload .jpg), binmode: true) do |tmp_file|
      tmp_file.write(
        Base64.decode64(
          '/9j/4QAiRXhpZgAATU0AKgAAAAgAAQESAAMAAAABAAYAAAA' \
          'AAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBA' \
          'QEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQE' \
          'BAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAEAAgMBEQACEQEDEQH/x' \
          'ABKAAEAAAAAAAAAAAAAAAAAAAALEAEAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAA' \
          'AAAAAEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwA/8H//2Q=='
        )
      )
      tmp_file.flush
      Account.representative.media_attachments.create!(file: tmp_file)
    end
  end
end
