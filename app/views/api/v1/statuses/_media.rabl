attributes :id, :remote_url, :type

node(:url)         { |media| full_asset_url(media.file.expiring_url(3600, :original)) }
node(:preview_url) { |media| full_asset_url(media.file.expiring_url(3600, :small)) }
