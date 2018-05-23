module PgHero
  class Engine < ::Rails::Engine
    isolate_namespace PgHero

    initializer "pghero", group: :all do |app|
      # check if Rails api mode
      if app.config.respond_to?(:assets)
        if defined?(Sprockets) && Sprockets::VERSION >= "4"
          app.config.assets.precompile << "pghero/application.js"
          app.config.assets.precompile << "pghero/application.css"
        else
          # use a proc instead of a string
          app.config.assets.precompile << proc { |path| path == "pghero/application.js" }
          app.config.assets.precompile << proc { |path| path == "pghero/application.css" }
        end
      end

      PgHero.time_zone = PgHero.config["time_zone"] if PgHero.config["time_zone"]
    end
  end
end
