require 'jsonapi/renderer/document'

module JSONAPI
  class Renderer
    # Render a JSON API document.
    #
    # @param params [Hash]
    #   @option data [(#jsonapi_id, #jsonapi_type, #jsonapi_related, #as_jsonapi),
    #           Array<(#jsonapi_id, #jsonapi_type, #jsonapi_related,
    #           #as_jsonapi)>,
    #           nil] Primary resource(s) to be rendered.
    #   @option errors [Array<#jsonapi_id>] Errors to be rendered.
    #   @option include Relationships to be included. See
    #     JSONAPI::IncludeDirective.
    #   @option fields [Hash{Symbol, Array<Symbol>}, Hash{String, Array<String>}]
    #     List of requested fields for some or all of the resource types.
    #   @option meta [Hash] Non-standard top-level meta information to be
    #     included.
    #   @option links [Hash] Top-level links to be included.
    #   @option jsonapi_object [Hash] JSON API object.
    def render(params)
      Document.new(params).to_hash
    end
  end

  module_function

  # @see JSONAPI::Renderer#render
  def render(params)
    Renderer.new.render(params)
  end
end
