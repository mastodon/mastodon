# frozen_string_literal: true

# Some S3-compatible providers might not actually be compatible with some APIs
# used by kt-paperclip, see https://github.com/mastodon/mastodon/issues/16822
if ENV['S3_ENABLED'] == 'true' && ENV['S3_FORCE_SINGLE_REQUEST'] == 'true'
  module Paperclip
    module Storage
      module S3Extensions
        def copy_to_local_file(style, local_dest_path)
          log("copying #{path(style)} to local file #{local_dest_path}")
          s3_object(style).download_file(local_dest_path, { mode: 'single_request' })
        rescue Aws::Errors::ServiceError => e
          warn("#{e} - cannot copy #{path(style)} to local file #{local_dest_path}")
          false
        end
      end
    end
  end

  Paperclip::Storage::S3.prepend(Paperclip::Storage::S3Extensions)
end
