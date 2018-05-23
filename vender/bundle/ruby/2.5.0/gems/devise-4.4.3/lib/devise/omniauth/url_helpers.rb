# frozen_string_literal: true

module Devise
  module OmniAuth
    module UrlHelpers
      def omniauth_authorize_path(resource_or_scope, provider, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        _devise_route_context.send("#{scope}_#{provider}_omniauth_authorize_path", *args)
      end

      def omniauth_authorize_url(resource_or_scope, provider, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        _devise_route_context.send("#{scope}_#{provider}_omniauth_authorize_url", *args)
      end

      def omniauth_callback_path(resource_or_scope, provider, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        _devise_route_context.send("#{scope}_#{provider}_omniauth_callback_path", *args)
      end

      def omniauth_callback_url(resource_or_scope, provider, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        _devise_route_context.send("#{scope}_#{provider}_omniauth_callback_url", *args)
      end
    end
  end
end
