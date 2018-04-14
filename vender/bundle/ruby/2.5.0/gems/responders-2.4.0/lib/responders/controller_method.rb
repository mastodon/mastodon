module Responders
  module ControllerMethod
    # Adds the given responders to the current controller's responder, allowing you to cherry-pick
    # which responders you want per controller.
    #
    #   class InvitationsController < ApplicationController
    #     responders :flash, :http_cache
    #   end
    #
    # Takes symbols and strings and translates them to VariableResponder (eg. :flash becomes FlashResponder).
    # Also allows passing in the responders modules in directly, so you could do:
    #
    #    responders FlashResponder, HttpCacheResponder
    #
    # Or a mix of both methods:
    #
    #    responders :flash, MyCustomResponder
    #
    def responders(*responders)
      self.responder = responders.inject(Class.new(responder)) do |klass, responder|
        responder = case responder
          when Module
            responder
          when String, Symbol
            Responders.const_get("#{responder.to_s.camelize}Responder")
          else
            raise "responder has to be a string, a symbol or a module"
          end

        klass.send(:include, responder)
        klass
      end
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  ActionController::Base.extend Responders::ControllerMethod
end
