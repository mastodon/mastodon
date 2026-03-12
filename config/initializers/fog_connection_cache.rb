# frozen_string_literal: true

if ENV['SWIFT_ENABLED'] == 'true'
  module PaperclipFogConnectionCache
    def connection
      @connection ||= begin
        key = fog_credentials.hash
        Thread.current[:paperclip_fog_connections] ||= {}
        Thread.current[:paperclip_fog_connections][key] ||= ::Fog::Storage.new(fog_credentials)
      end
    end
  end

  Rails.application.config.after_initialize do
    Paperclip::Storage::Fog.prepend(PaperclipFogConnectionCache)
  end
end
