SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |nav|
    nav.item :item_1, 'Item 1', '/item_1', html: {class: 'item_1'}, link_html: {id: 'link_1'}
    nav.item :item_2, 'Item 2', '/item_2', html: {class: 'item_2'}, link_html: {id: 'link_2'}
  end
end
