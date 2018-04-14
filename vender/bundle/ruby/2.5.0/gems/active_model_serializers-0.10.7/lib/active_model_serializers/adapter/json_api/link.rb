module ActiveModelSerializers
  module Adapter
    class JsonApi
      # link
      # definition:
      #  oneOf
      #    linkString
      #    linkObject
      #
      # description:
      #   A link **MUST** be represented as either: a string containing the link's URL or a link
      #   object."
      # structure:
      #   if href?
      #     linkString
      #   else
      #     linkObject
      #   end
      #
      # linkString
      # definition:
      #   URI
      #
      # description:
      #   A string containing the link's URL.
      # structure:
      #  'http://example.com/link-string'
      #
      # linkObject
      # definition:
      #   JSON Object
      #
      # properties:
      #   href (required) : URI
      #   meta
      # structure:
      #   {
      #     href: 'http://example.com/link-object',
      #     meta: meta,
      #   }.reject! {|_,v| v.nil? }
      class Link
        include SerializationContext::UrlHelpers

        def initialize(serializer, value)
          @_routes ||= nil # handles warning
          # actionpack-4.0.13/lib/action_dispatch/routing/route_set.rb:417: warning: instance variable @_routes not initialized
          @object = serializer.object
          @scope = serializer.scope
          # Use the return value of the block unless it is nil.
          if value.respond_to?(:call)
            @value = instance_eval(&value)
          else
            @value = value
          end
        end

        def href(value)
          @href = value
          nil
        end

        def meta(value)
          @meta = value
          nil
        end

        def as_json
          return @value if @value

          hash = {}
          hash[:href] = @href if defined?(@href)
          hash[:meta] = @meta if defined?(@meta)

          hash.any? ? hash : nil
        end

        protected

        attr_reader :object, :scope
      end
    end
  end
end
