object @card

attributes :url, :title, :description, :type,
           :author_name, :author_url, :provider_name,
           :provider_url, :html, :width, :height

node(:image) { |card| card.image? ? full_asset_url(card.image.url(:original)) : nil }
