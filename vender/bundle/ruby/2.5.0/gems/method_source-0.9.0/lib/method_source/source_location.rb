module MethodSource
  module ReeSourceLocation
    # Ruby enterprise edition provides all the information that's
    # needed, in a slightly different way.
    def source_location
      [__file__, __line__] rescue nil
    end
  end

  module SourceLocation
    module MethodExtensions
      if Proc.method_defined? :__file__
        include ReeSourceLocation

      elsif defined?(RUBY_ENGINE) && RUBY_ENGINE =~ /jruby/
        require 'java'

        # JRuby version source_location hack
        # @return [Array] A two element array containing the source location of the method
        def source_location
          to_java.source_location(Thread.current.to_java.getContext())
        end
      else


        def trace_func(event, file, line, id, binding, classname)
          return unless event == 'call'
          set_trace_func nil

          @file, @line = file, line
          raise :found
        end

        private :trace_func

        # Return the source location of a method for Ruby 1.8.
        # @return [Array] A two element array. First element is the
        #   file, second element is the line in the file where the
        #   method definition is found.
        def source_location
          if @file.nil?
            args =[*(1..(arity<-1 ? -arity-1 : arity ))]

            set_trace_func method(:trace_func).to_proc
            call(*args) rescue nil
            set_trace_func nil
            @file = File.expand_path(@file) if @file && File.exist?(File.expand_path(@file))
          end
          [@file, @line] if @file
        end
      end
    end

    module ProcExtensions
      if Proc.method_defined? :__file__
        include ReeSourceLocation

      elsif defined?(RUBY_ENGINE) && RUBY_ENGINE =~ /rbx/

        # Return the source location for a Proc (Rubinius only)
        # @return [Array] A two element array. First element is the
        #   file, second element is the line in the file where the
        #   proc definition is found.
        def source_location
          [block.file.to_s, block.line]
        end
      else

        # Return the source location for a Proc (in implementations
        # without Proc#source_location)
        # @return [Array] A two element array. First element is the
        #   file, second element is the line in the file where the
        #   proc definition is found.
        def source_location
          self.to_s =~ /@(.*):(\d+)/
          [$1, $2.to_i]
        end
      end
    end

    module UnboundMethodExtensions
      if Proc.method_defined? :__file__
        include ReeSourceLocation

      elsif defined?(RUBY_ENGINE) && RUBY_ENGINE =~ /jruby/
        require 'java'

        # JRuby version source_location hack
        # @return [Array] A two element array containing the source location of the method
        def source_location
          to_java.source_location(Thread.current.to_java.getContext())
        end

      else


        # Return the source location of an instance method for Ruby 1.8.
        # @return [Array] A two element array. First element is the
        #   file, second element is the line in the file where the
        #   method definition is found.
        def source_location
          klass = case owner
                  when Class
                    owner
                  when Module
                    method_owner = owner
                    Class.new { include(method_owner) }
                  end

          # deal with immediate values
          case
          when klass == Symbol
            return :a.method(name).source_location
          when klass == Integer
            return 0.method(name).source_location
          when klass == TrueClass
            return true.method(name).source_location
          when klass == FalseClass
            return false.method(name).source_location
          when klass == NilClass
            return nil.method(name).source_location
          end

          begin
            Object.instance_method(:method).bind(klass.allocate).call(name).source_location
          rescue TypeError

            # Assume we are dealing with a Singleton Class:
            # 1. Get the instance object
            # 2. Forward the source_location lookup to the instance
            instance ||= ObjectSpace.each_object(owner).first
            Object.instance_method(:method).bind(instance).call(name).source_location
          end
        end
      end
    end
  end
end
