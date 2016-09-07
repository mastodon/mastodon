object @media
attribute :id
node(:url) { |media| full_asset_url(media.file.url) }
node(:preview_url) { |media| full_asset_url(media.file.url(:small)) }
