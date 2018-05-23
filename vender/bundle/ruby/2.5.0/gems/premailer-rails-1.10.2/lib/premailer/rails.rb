require 'premailer'
require 'action_mailer'

require 'premailer/rails/version'
require 'premailer/rails/css_loaders'
require 'premailer/rails/css_helper'
require 'premailer/rails/customized_premailer'
require 'premailer/rails/hook'

class Premailer
  module Rails
    @config = {
      input_encoding: 'UTF-8',
      generate_text_part: true,
      strategies: [:filesystem, :asset_pipeline, :network]
    }
    class << self
      attr_accessor :config
    end

    def self.register_interceptors
      ActionMailer::Base.register_interceptor(Premailer::Rails::Hook)

      if ActionMailer::Base.respond_to?(:register_preview_interceptor)
        ActionMailer::Base.register_preview_interceptor(Premailer::Rails::Hook)
      end
    end
  end
end

require 'premailer/rails/railtie' if defined?(Rails)
