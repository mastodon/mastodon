module ThreadSafe
  class MriCacheBackend < NonConcurrentCacheBackend
    # We can get away with a single global write lock (instead of a per-instance
    # one) because of the GVL/green threads.
    #
    # NOTE: a neat idea of writing a c-ext to manually perform atomic
    # put_if_absent, while relying on Ruby not releasing a GVL while calling a
    # c-ext will not work because of the potentially Ruby implemented `#hash`
    # and `#eql?` key methods.
    WRITE_LOCK = Mutex.new

    def []=(key, value)
      WRITE_LOCK.synchronize { super }
    end

    def compute_if_absent(key)
      if stored_value = _get(key) # fast non-blocking path for the most likely case
        stored_value
      else
        WRITE_LOCK.synchronize { super }
      end
    end

    def compute_if_present(key)
      WRITE_LOCK.synchronize { super }
    end

    def compute(key)
      WRITE_LOCK.synchronize { super }
    end

    def merge_pair(key, value)
      WRITE_LOCK.synchronize { super }
    end

    def replace_pair(key, old_value, new_value)
      WRITE_LOCK.synchronize { super }
    end

    def replace_if_exists(key, new_value)
      WRITE_LOCK.synchronize { super }
    end

    def get_and_set(key, value)
      WRITE_LOCK.synchronize { super }
    end

    def delete(key)
      WRITE_LOCK.synchronize { super }
    end

    def delete_pair(key, value)
      WRITE_LOCK.synchronize { super }
    end

    def clear
      WRITE_LOCK.synchronize { super }
    end
  end
end
