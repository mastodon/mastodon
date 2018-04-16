module ThreadSafe
  class SynchronizedCacheBackend < NonConcurrentCacheBackend
    require 'mutex_m'
    include Mutex_m
    # WARNING: Mutex_m is a non-reentrant lock, so the synchronized methods are
    # not allowed to call each other.

    def [](key)
      synchronize { super }
    end

    def []=(key, value)
      synchronize { super }
    end

    def compute_if_absent(key)
      synchronize { super }
    end

    def compute_if_present(key)
      synchronize { super }
    end

    def compute(key)
      synchronize { super }
    end

    def merge_pair(key, value)
      synchronize { super }
    end

    def replace_pair(key, old_value, new_value)
      synchronize { super }
    end

    def replace_if_exists(key, new_value)
      synchronize { super }
    end

    def get_and_set(key, value)
      synchronize { super }
    end

    def key?(key)
      synchronize { super }
    end

    def value?(value)
      synchronize { super }
    end

    def delete(key)
      synchronize { super }
    end

    def delete_pair(key, value)
      synchronize { super }
    end

    def clear
      synchronize { super }
    end

    def size
      synchronize { super }
    end

    def get_or_default(key, default_value)
      synchronize { super }
    end

    private
    def dupped_backend
      synchronize { super }
    end
  end
end
