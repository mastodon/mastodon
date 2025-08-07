# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  # Solo suprimir warnings CSRF en test environment
  # En producción, mantener logs para detectar ataques potenciales
  if Rails.env.test?
    ActionController::Base.log_warning_on_csrf_failure = false
  else
    ActionController::Base.log_warning_on_csrf_failure = true
    
    # Configurar callback para registrar intentos CSRF sospechosos
    ActionController::Base.prepend(Module.new do
      def handle_unverified_request
        Rails.logger.warn("CSRF token verification failed for #{request.remote_ip} - #{request.path}")
        super
      end
    end)
  end
end
