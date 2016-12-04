attributes :id, :remote_url, :type

node(:url)         { |media| full_asset_url(media.file.expiring_url(s3_expiry, :original)) }
node(:preview_url) { |media| full_asset_url(media.file.expiring_url(s3_expiry, :small)) }
