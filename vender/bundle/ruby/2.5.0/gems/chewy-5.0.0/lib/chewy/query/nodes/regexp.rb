module Chewy
  class Query
    module Nodes
      class Regexp < Expr
        FLAGS = %w[all anystring automaton complement empty intersection interval none].freeze

        def initialize(name, regexp, *args)
          @name = name.to_s
          @regexp = regexp.respond_to?(:source) ? regexp.source : regexp.to_s
          @options = args.extract_options!
          return if args.blank? && @options[:flags].blank?
          @options[:flags] = FLAGS & (args.present? ? args.flatten : @options[:flags]).map(&:to_s).map(&:downcase)
        end

        def __render__
          body = if @options[:flags]
            {value: @regexp, flags: @options[:flags].map(&:to_s).map(&:upcase).uniq.join('|')}
          else
            @regexp
          end
          filter = {@name => body}
          if @options.key?(:cache)
            filter[:_cache] = !!@options[:cache]
            filter[:_cache_key] = if @options[:cache].is_a?(TrueClass) || @options[:cache].is_a?(FalseClass)
              @regexp.underscore
            else
              @options[:cache]
            end
          end
          {regexp: filter}
        end
      end
    end
  end
end
