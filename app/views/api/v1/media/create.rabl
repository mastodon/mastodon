object @media
attribute :id, :type
node(:url) { |media| full_asset_url(media.file.expiring_url(s3_expiry, :original)) }
node(:preview_url) { |media| full_asset_url(media.file.expiring_url(s3_expiry, :small)) }
node(:text_url) { |media| medium_url(media) }
