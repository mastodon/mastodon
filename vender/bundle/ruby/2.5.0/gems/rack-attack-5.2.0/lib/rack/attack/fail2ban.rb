module Rack
  class Attack
    class Fail2Ban
      class << self
        def filter(discriminator, options)
          bantime   = options[:bantime]   or raise ArgumentError, "Must pass bantime option"
          findtime  = options[:findtime]  or raise ArgumentError, "Must pass findtime option"
          maxretry  = options[:maxretry]  or raise ArgumentError, "Must pass maxretry option"

          if banned?(discriminator)
            # Return true for blocklist
            true
          elsif yield
            fail!(discriminator, bantime, findtime, maxretry)
          end
        end

        def reset(discriminator, options)
          findtime = options[:findtime] or raise ArgumentError, "Must pass findtime option"
          cache.reset_count("#{key_prefix}:count:#{discriminator}", findtime)
          # Clear ban flag just in case it's there
          cache.delete("#{key_prefix}:ban:#{discriminator}")
        end

        def banned?(discriminator)
          cache.read("#{key_prefix}:ban:#{discriminator}") ? true : false
        end

        protected
        def key_prefix
          'fail2ban'
        end

        def fail!(discriminator, bantime, findtime, maxretry)
          count = cache.count("#{key_prefix}:count:#{discriminator}", findtime)
          if count >= maxretry
            ban!(discriminator, bantime)
          end

          true
        end


        private
        def ban!(discriminator, bantime)
          cache.write("#{key_prefix}:ban:#{discriminator}", 1, bantime)
        end

        def cache
          Rack::Attack.cache
        end
      end
    end
  end
end
