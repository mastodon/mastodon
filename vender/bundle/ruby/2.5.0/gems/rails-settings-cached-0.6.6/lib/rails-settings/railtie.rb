module RailsSettings
  class Railtie < Rails::Railtie
    initializer 'rails_settings.active_record.initialization' do
      RailsSettings::Base.after_commit :rewrite_cache, on: %i(create update)
      RailsSettings::Base.after_commit :expire_cache, on: %i(destroy)
    end
  end
end
