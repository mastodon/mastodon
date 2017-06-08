object @media
attribute :id, :type

node(:url)         { |media| full_asset_url(media.file.url(:original)) }
node(:preview_url) { |media| full_asset_url(media.file.url(:small)) }
node(:text_url)    { |media| medium_url(media) }
node(:meta)        { |media| media.file.meta }
