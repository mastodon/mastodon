object @card

attributes :url, :title, :description

node(:image) { |card| card.image? ? full_asset_url(card.image.url(:original)) : nil }
