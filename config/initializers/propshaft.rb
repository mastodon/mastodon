# frozen_string_literal: true

# SVG Icons
Rails.application.config.assets.paths << Rails.root.join('app', 'javascript', 'images')

# Tell propshaft where the material design icons are
Rails.application.config.assets.paths << Rails.root.join('app', 'javascript', 'material-icons')
