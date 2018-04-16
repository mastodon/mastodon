module Bootsnap
  module LoadPathCache
    module CoreExt
      module ActiveSupport
        def self.without_bootsnap_cache
          prev = Thread.current[:without_bootsnap_cache] || false
          Thread.current[:without_bootsnap_cache] = true
          yield
        ensure
          Thread.current[:without_bootsnap_cache] = prev
        end

        module ClassMethods
          def autoload_paths=(o)
            super
            Bootsnap::LoadPathCache.autoload_paths_cache.reinitialize(o)
          end

          def search_for_file(path)
            return super if Thread.current[:without_bootsnap_cache]
            begin
              Bootsnap::LoadPathCache.autoload_paths_cache.find(path)
            rescue Bootsnap::LoadPathCache::ReturnFalse
              nil # doesn't really apply here
            end
          end

          def autoloadable_module?(path_suffix)
            Bootsnap::LoadPathCache.autoload_paths_cache.has_dir?(path_suffix)
          end

          def remove_constant(const)
            CoreExt::ActiveSupport.without_bootsnap_cache { super }
          end

          # If we can't find a constant using the patched implementation of
          # search_for_file, try again with the default implementation.
          #
          # These methods call search_for_file, and we want to modify its
          # behaviour.  The gymnastics here are a bit awkward, but it prevents
          # 200+ lines of monkeypatches.
          def load_missing_constant(from_mod, const_name)
            super
          rescue NameError => e
            # NoMethodError is a NameError, but we only want to handle actual
            # NameError instances.
            raise unless e.class == NameError
            # We can only confidently handle cases when *this* constant fails
            # to load, not other constants referred to by it.
            raise unless e.name == const_name
            # If the constant was actually loaded, something else went wrong?
            raise if from_mod.const_defined?(const_name)
            CoreExt::ActiveSupport.without_bootsnap_cache { super }
          end

          # Signature has changed a few times over the years; easiest to not
          # reiterate it with version polymorphism here...
          def depend_on(*)
            super
          rescue LoadError
            CoreExt::ActiveSupport.without_bootsnap_cache { super }
          end
        end
      end
    end
  end
end

module ActiveSupport
  module Dependencies
    class << self
      prepend Bootsnap::LoadPathCache::CoreExt::ActiveSupport::ClassMethods
    end
  end
end
