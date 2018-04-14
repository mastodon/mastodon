module Chewy
  class Type
    module Observe
      extend ActiveSupport::Concern

      module Helpers
        def update_proc(type_name, *args, &block)
          options = args.extract_options!
          method = args.first

          proc do
            reference = if type_name.is_a?(Proc)
              if type_name.arity.zero?
                instance_exec(&type_name)
              else
                type_name.call(self)
              end
            else
              type_name
            end

            type = Chewy.derive_type(reference)

            next if Chewy.strategy.current.name == :bypass

            backreference = if method && method.to_s == 'self'
              self
            elsif method
              send(method)
            else
              instance_eval(&block)
            end

            type.update_index(backreference, options)
          end
        end

        def extract_callback_options!(args)
          options = args.extract_options!
          result = options.each_key.with_object({}) do |key, hash|
            hash[key] = options.delete(key) if %i[if unless].include?(key)
          end
          args.push(options) unless options.empty?
          result
        end
      end

      extend Helpers

      module MongoidMethods
        def update_index(type_name, *args, &block)
          callback_options = Observe.extract_callback_options!(args)
          update_proc = Observe.update_proc(type_name, *args, &block)

          after_save(callback_options, &update_proc)
          after_destroy(callback_options, &update_proc)
        end
      end

      module ActiveRecordMethods
        def update_index(type_name, *args, &block)
          callback_options = Observe.extract_callback_options!(args)
          update_proc = Observe.update_proc(type_name, *args, &block)

          if Chewy.use_after_commit_callbacks
            after_commit(callback_options, &update_proc)
          else
            after_save(callback_options, &update_proc)
            after_destroy(callback_options, &update_proc)
          end
        end
      end

      module ClassMethods
        def update_index(objects, options = {})
          Chewy.strategy.current.update(self, objects, options)
          true
        end
      end
    end
  end
end
