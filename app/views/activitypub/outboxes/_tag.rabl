node(:type) { 'Hashtag' }
node(:href) { |tag| tag_url(tag) }
node(:name) { |tag| "##{tag.name}" }
