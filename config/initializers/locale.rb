# frozen_string_literal: true

Rails.application.configure do
  I18n.load_path += Dir[Rails.root.join('app', 'javascript', 'flavours', '*', 'names.{rb,yml}').to_s]
  I18n.load_path += Dir[Rails.root.join('app', 'javascript', 'flavours', '*', 'names', '*.{rb,yml}').to_s]
  I18n.load_path += Dir[Rails.root.join('app', 'javascript', 'skins', '*', '*', 'names.{rb,yml}').to_s]
  I18n.load_path += Dir[Rails.root.join('app', 'javascript', 'skins', '*', '*', 'names', '*.{rb,yml}').to_s]
  I18n.load_path += Dir[Rails.root.join('config', 'locales-glitch', '*.{rb,yml}').to_s]
end
