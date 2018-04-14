class Premailer
  module Rails
    class Railtie < ::Rails::Railtie
      config.after_initialize do
        ::Premailer::Rails.register_interceptors
      end
    end
  end
end
