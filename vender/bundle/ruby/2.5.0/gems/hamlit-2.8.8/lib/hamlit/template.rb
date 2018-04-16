# frozen_string_literal: false
require 'temple'
require 'hamlit/engine'
require 'hamlit/helpers'

# Load tilt/haml first to override if available
begin
  require 'haml'
rescue LoadError
else
  require 'tilt/haml'
end

module Hamlit
  Template = Temple::Templates::Tilt.create(
    Hamlit::Engine,
    register_as: :haml,
  )

  module TemplateExtension
    # Activate Hamlit::Helpers for tilt templates.
    # https://github.com/judofyr/temple/blob/v0.7.6/lib/temple/mixins/template.rb#L7-L11
    def compile(*)
      "extend Hamlit::Helpers; #{super}"
    end
  end
  Template.send(:extend, TemplateExtension)
end
