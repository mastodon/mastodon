module ClimateControl
  class Modifier
    def initialize(env, environment_overrides = {}, &block)
      @environment_overrides = stringify_keys(environment_overrides)
      @block = block
      @env = env
    end

    def process
      @env.synchronize do
        begin
          prepare_environment_for_block
          run_block
        ensure
          cache_environment_after_block
          delete_keys_that_do_not_belong
          revert_changed_keys
        end
      end
    end

    private

    def prepare_environment_for_block
      @original_env = clone_environment
      copy_overrides_to_environment
      @env_with_overrides_before_block = clone_environment
    end

    def run_block
      @block.call
    end

    def copy_overrides_to_environment
      @environment_overrides.each do |key, value|
        begin
          @env[key] = value
        rescue TypeError => e
          raise UnassignableValueError,
            "attempted to assign #{value} to #{key} but failed (#{e.message})"
        end
      end
    end

    def keys_to_remove
      @environment_overrides.keys
    end

    def keys_changed_by_block
      @keys_changed_by_block ||= OverlappingKeysWithChangedValues.new(@env_with_overrides_before_block, @env_after_block).keys
    end

    def cache_environment_after_block
      @env_after_block = clone_environment
    end

    def delete_keys_that_do_not_belong
      (keys_to_remove - keys_changed_by_block).each {|key| @env.delete(key) }
    end

    def revert_changed_keys
      (@original_env.keys - keys_changed_by_block).each do |key|
        @env[key] = @original_env[key]
      end
    end

    def clone_environment
      @env.to_hash
    end

    def stringify_keys(env)
      env.each_with_object({}) do |(key, value), hash|
        hash[key.to_s] = value
      end
    end

    class OverlappingKeysWithChangedValues
      def initialize(hash_1, hash_2)
        @hash_1 = hash_1 || {}
        @hash_2 = hash_2
      end

      def keys
        overlapping_keys.select do |overlapping_key|
          @hash_1[overlapping_key] != @hash_2[overlapping_key]
        end
      end

      private

      def overlapping_keys
        @hash_2.keys & @hash_1.keys
      end
    end
  end
end
