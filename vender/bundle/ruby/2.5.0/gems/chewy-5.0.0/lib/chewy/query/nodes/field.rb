module Chewy
  class Query
    module Nodes
      class Field < Base
        def initialize(name, *args)
          @name = name.to_s
          @args = args
        end

        def !
          Nodes::Missing.new @name
        end

        def ~
          __options_merge__!(cache: true)
          self
        end

        def >(other)
          Nodes::Range.new @name, *__options_merge__(gt: other)
        end

        def <(other)
          Nodes::Range.new @name, *__options_merge__(lt: other)
        end

        def >=(other)
          Nodes::Range.new @name, *__options_merge__(gt: other, left_closed: true)
        end

        def <=(other)
          Nodes::Range.new @name, *__options_merge__(lt: other, right_closed: true)
        end

        def ==(other)
          case other
          when nil
            nil?
          when ::Regexp
            Nodes::Regexp.new @name, other, *@args
          when ::Range
            Nodes::Range.new @name, *__options_merge__(gt: other.first, lt: other.last)
          else
            if other.is_a?(Array) && other.first.is_a?(::Range)
              Nodes::Range.new @name, *__options_merge__(
                gt: other.first.first, lt: other.first.last,
                left_closed: true, right_closed: true
              )
            else
              Nodes::Equal.new @name, other, *@args
            end
          end
        end

        def !=(other)
          case other
          when nil
            Nodes::Exists.new @name
          else
            Nodes::Not.new self == other
          end
        end

        def =~(other)
          case other
          when ::Regexp
            Nodes::Regexp.new @name, other, *@args
          else
            Nodes::Prefix.new @name, other, @args.extract_options!
          end
        end

        def !~(other)
          Not.new(self =~ other)
        end

        def nil?
          Nodes::Missing.new @name, existence: false, null_value: true
        end

        def method_missing(method, *args) # rubocop:disable Style/MethodMissing
          method = method.to_s
          if method =~ /\?\Z/
            Nodes::Exists.new [@name, method.gsub(/\?\Z/, '')].join('.')
          else
            self.class.new [@name, method].join('.'), *args
          end
        end

        def to_ary
          nil
        end

      private

        def __options_merge__!(additional = {})
          options = @args.extract_options!
          options = options.merge(additional)
          @args.push(options)
        end

        def __options_merge__(additional = {})
          options = @args.extract_options!
          options = options.merge(additional)
          @args + [options]
        end
      end
    end
  end
end
