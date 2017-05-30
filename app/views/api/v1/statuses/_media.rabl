attributes :id, :remote_url, :type

node(:url)         { |media| full_asset_url(media.file.url(:original)) }
node(:preview_url) { |media| full_asset_url(media.file.url(:small)) }
node(:text_url)    { |media| media.local? ? medium_url(media) : nil }
node(:meta)        { |media| media.file.meta }
