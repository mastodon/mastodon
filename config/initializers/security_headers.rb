# frozen_string_literal: true

Rails.application.configure do
  # Security Headers middleware
  config.middleware.insert_before ActionDispatch::Static, Rack::Attack

  # Additional Security Headers
  config.force_ssl = true if Rails.env.production?
  
  # Configurar headers de seguridad adicionales
  config.middleware.insert_after ActionDispatch::Static, Rack::Deflater
  
  # Aplicar headers de seguridad a todas las respuestas
  config.middleware.use(Class.new do
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)
      
      # Security Headers
      headers['X-Frame-Options'] = 'DENY'
      headers['X-Content-Type-Options'] = 'nosniff'
      headers['X-XSS-Protection'] = '1; mode=block'
      headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
      headers['Permissions-Policy'] = 'accelerometer=(), ambient-light-sensor=(), autoplay=(), battery=(), camera=(), display-capture=(), document-domain=(), encrypted-media=(), execution-while-not-rendered=(), execution-while-out-of-viewport=(), fullscreen=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), midi=(), navigation-override=(), payment=(), picture-in-picture=(), publickey-credentials-get=(), screen-wake-lock=(), sync-xhr=(), usb=(), web-share=(), xr-spatial-tracking=()'
      
      if Rails.env.production?
        # HSTS Header (solo en producción con HTTPS)
        headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains; preload'
      end

      [status, headers, response]
    end
  end)
end
