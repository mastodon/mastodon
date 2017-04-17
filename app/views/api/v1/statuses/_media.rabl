attributes :id, :remote_url, :type

node(:url)         { |media| media.file.blank? ? media.remote_url : full_asset_url(media.file.url(:original)) }
node(:preview_url) { |media| media.file.blank? ? media.remote_url : full_asset_url(media.file.url(:small)) }
node(:text_url)    { |media| media.local? ? medium_url(media) : nil }
