Thread.abort_on_exception = true

module ThreadSafe
  describe 'CacheTorture' do
    THREAD_COUNT  = 40
    KEY_COUNT     = (((2**13) - 2) * 0.75).to_i # get close to the doubling cliff
    LOW_KEY_COUNT = (((2**8 ) - 2) * 0.75).to_i # get close to the doubling cliff

    INITIAL_VALUE_CACHE_SETUP = lambda do |options, keys|
      cache         = ThreadSafe::Cache.new
      initial_value = options[:initial_value] || 0
      keys.each { |key| cache[key] = initial_value }
      cache
    end
    ZERO_VALUE_CACHE_SETUP = lambda do |options, keys|
      INITIAL_VALUE_CACHE_SETUP.call(options.merge(:initial_value => 0), keys)
    end

    DEFAULTS = {
      key_count:    KEY_COUNT,
      thread_count: THREAD_COUNT,
      loop_count:   1,
      prelude:      '',
      cache_setup:  lambda { |options, keys| ThreadSafe::Cache.new }
    }

    LOW_KEY_COUNT_OPTIONS    = {loop_count: 150,     key_count: LOW_KEY_COUNT}
    SINGLE_KEY_COUNT_OPTIONS = {loop_count: 100_000, key_count: 1}

    it 'concurrency' do
      code = <<-RUBY_EVAL
        cache[key]
        cache[key] = key
        cache[key]
        cache.delete(key)
      RUBY_EVAL
      do_thread_loop(:concurrency, code)
    end

    it '#put_if_absent' do
      do_thread_loop(
        :put_if_absent, 
        'acc += 1 unless cache.put_if_absent(key, key)', 
        key_count: 100_000
      ) do |result, cache, options, keys|
        expect_standard_accumulator_test_result(result, cache, options, keys)
      end
    end

    it '#compute_put_if_absent' do
      code = <<-RUBY_EVAL
        if key.even?
          cache.compute_if_absent(key) { acc += 1; key }
        else
          acc += 1 unless cache.put_if_absent(key, key)
        end
      RUBY_EVAL
      do_thread_loop(:compute_if_absent, code) do |result, cache, options, keys|
        expect_standard_accumulator_test_result(result, cache, options, keys)
      end
    end

    it '#compute_if_absent_and_present' do
      compute_if_absent_and_present
      compute_if_absent_and_present(LOW_KEY_COUNT_OPTIONS)
      compute_if_absent_and_present(SINGLE_KEY_COUNT_OPTIONS)
    end

    it 'add_remove_to_zero' do
      add_remove_to_zero
      add_remove_to_zero(LOW_KEY_COUNT_OPTIONS)
      add_remove_to_zero(SINGLE_KEY_COUNT_OPTIONS)
    end

    it 'add_remove_to_zero_via_merge_pair' do
      add_remove_to_zero_via_merge_pair
      add_remove_to_zero_via_merge_pair(LOW_KEY_COUNT_OPTIONS)
      add_remove_to_zero_via_merge_pair(SINGLE_KEY_COUNT_OPTIONS)
    end

    it 'add_remove' do
      add_remove
      add_remove(LOW_KEY_COUNT_OPTIONS)
      add_remove(SINGLE_KEY_COUNT_OPTIONS)
    end

    it 'add_remove_via_compute' do
      add_remove_via_compute
      add_remove_via_compute(LOW_KEY_COUNT_OPTIONS)
      add_remove_via_compute(SINGLE_KEY_COUNT_OPTIONS)
    end

    it 'emove_via_compute_if_absent_present' do
      add_remove_via_compute_if_absent_present
      add_remove_via_compute_if_absent_present(LOW_KEY_COUNT_OPTIONS)
      add_remove_via_compute_if_absent_present(SINGLE_KEY_COUNT_OPTIONS)
    end

    it 'add_remove_indiscriminate' do
      add_remove_indiscriminate
      add_remove_indiscriminate(LOW_KEY_COUNT_OPTIONS)
      add_remove_indiscriminate(SINGLE_KEY_COUNT_OPTIONS)
    end

    it 'count_up' do
      count_up
      count_up(LOW_KEY_COUNT_OPTIONS)
      count_up(SINGLE_KEY_COUNT_OPTIONS)
    end

    it 'count_up_via_compute' do
      count_up_via_compute
      count_up_via_compute(LOW_KEY_COUNT_OPTIONS)
      count_up_via_compute(SINGLE_KEY_COUNT_OPTIONS)
    end

    it 'count_up_via_merge_pair' do
      count_up_via_merge_pair
      count_up_via_merge_pair(LOW_KEY_COUNT_OPTIONS)
      count_up_via_merge_pair(SINGLE_KEY_COUNT_OPTIONS)
    end

    it 'count_race' do
      prelude = 'change = (rand(2) == 1) ? 1 : -1'
      code = <<-RUBY_EVAL
        v = cache[key]
        acc += change if cache.replace_pair(key, v, v + change)
      RUBY_EVAL
      do_thread_loop(
        :count_race, 
        code, 
        loop_count: 5, 
        prelude: prelude, 
        cache_setup: ZERO_VALUE_CACHE_SETUP
      ) do |result, cache, options, keys|
        result_sum = sum(result)
        expect(sum(keys.map { |key| cache[key] })).to eq result_sum
        expect(sum(cache.values)).to eq result_sum
        expect(options[:key_count]).to eq cache.size
      end
    end

    it 'get_and_set_new' do
      code = 'acc += 1 unless cache.get_and_set(key, key)'
      do_thread_loop(:get_and_set_new, code) do |result, cache, options, keys|
        expect_standard_accumulator_test_result(result, cache, options, keys)
      end
    end

    it 'get_and_set_existing' do
      code = 'acc += 1 if cache.get_and_set(key, key) == -1'
      do_thread_loop(
        :get_and_set_existing, 
        code, 
        cache_setup: INITIAL_VALUE_CACHE_SETUP, 
        initial_value: -1
      ) do |result, cache, options, keys|
        expect_standard_accumulator_test_result(result, cache, options, keys)
      end
    end

    private

    def compute_if_absent_and_present(opts = {})
      prelude = 'on_present = rand(2) == 1'
      code = <<-RUBY_EVAL
        if on_present
          cache.compute_if_present(key) { |old_value| acc += 1; old_value + 1 }
        else
          cache.compute_if_absent(key)  { acc += 1; 1 }
        end
      RUBY_EVAL
      do_thread_loop(
        __method__, 
        code, 
        {loop_count: 5, prelude: prelude}.merge(opts)
      ) do |result, cache, options, keys|
        stored_sum       = 0
        stored_key_count = 0
        keys.each do |k|
          if value = cache[k]
            stored_sum += value
            stored_key_count += 1
          end
        end
        expect(stored_sum).to eq sum(result)
        expect(stored_key_count).to eq cache.size
      end
    end

    def add_remove(opts = {})
      prelude = 'do_add = rand(2) == 1'
      code = <<-RUBY_EVAL
        if do_add
          acc += 1 unless cache.put_if_absent(key, key)
        else
          acc -= 1 if cache.delete_pair(key, key)
        end
      RUBY_EVAL
      do_thread_loop(
        __method__, 
        code, 
        {loop_count: 5, prelude: prelude}.merge(opts)
      ) do |result, cache, options, keys|
        expect_all_key_mappings_exist(cache, keys, false)
        expect(cache.size).to eq sum(result)
      end
    end

    def add_remove_via_compute(opts = {})
      prelude = 'do_add = rand(2) == 1'
      code = <<-RUBY_EVAL
        cache.compute(key) do |old_value|
          if do_add
            acc += 1 unless old_value
            key
          else
            acc -= 1 if old_value
            nil
          end
        end
      RUBY_EVAL
      do_thread_loop(
        __method__, 
        code, 
        {loop_count: 5, prelude: prelude}.merge(opts)
      ) do |result, cache, options, keys|
        expect_all_key_mappings_exist(cache, keys, false)
        expect(cache.size).to eq sum(result)
      end
    end

    def add_remove_via_compute_if_absent_present(opts = {})
      prelude = 'do_add = rand(2) == 1'
      code = <<-RUBY_EVAL
        if do_add
          cache.compute_if_absent(key)  { acc += 1; key }
        else
          cache.compute_if_present(key) { acc -= 1; nil }
        end
      RUBY_EVAL
      do_thread_loop(
        __method__, 
        code, 
        {loop_count: 5, prelude: prelude}.merge(opts)
      ) do |result, cache, options, keys|
        expect_all_key_mappings_exist(cache, keys, false)
        expect(cache.size).to eq sum(result)
      end
    end

    def add_remove_indiscriminate(opts = {})
      prelude = 'do_add = rand(2) == 1'
      code = <<-RUBY_EVAL
        if do_add
          acc += 1 unless cache.put_if_absent(key, key)
        else
          acc -= 1 if cache.delete(key)
        end
      RUBY_EVAL
      do_thread_loop(
        __method__, 
        code, 
        {loop_count: 5, prelude: prelude}.merge(opts)
      ) do |result, cache, options, keys|
        expect_all_key_mappings_exist(cache, keys, false)
        expect(cache.size).to eq sum(result)
      end
    end

    def count_up(opts = {})
      code = <<-RUBY_EVAL
        v = cache[key]
        acc += 1 if cache.replace_pair(key, v, v + 1)
      RUBY_EVAL
      do_thread_loop(
        __method__, 
        code, 
        {loop_count: 5, cache_setup: ZERO_VALUE_CACHE_SETUP}.merge(opts)
      ) do |result, cache, options, keys|
        expect_count_up(result, cache, options, keys)
      end
    end

    def count_up_via_compute(opts = {})
      code = <<-RUBY_EVAL
        cache.compute(key) do |old_value|
          acc += 1
          old_value ? old_value + 1 : 1
        end
      RUBY_EVAL
      do_thread_loop(
        __method__, 
        code, {loop_count: 5}.merge(opts)
      ) do |result, cache, options, keys|
        expect_count_up(result, cache, options, keys)
        result.inject(nil) do |previous_value, next_value| # since compute guarantees atomicity all count ups should be equal
          expect(previous_value).to eq next_value if previous_value
          next_value
        end
      end
    end

    def count_up_via_merge_pair(opts = {})
      code = <<-RUBY_EVAL
        cache.merge_pair(key, 1) { |old_value| old_value + 1 }
      RUBY_EVAL
      do_thread_loop(
        __method__, 
        code, 
        {loop_count: 5}.merge(opts)
      ) do |result, cache, options, keys|
        all_match      = true
        expected_value = options[:loop_count] * options[:thread_count]
        keys.each do |key|
          value = cache[key]
          if expected_value != value
            all_match = false
            break
          end
        end
        expect(all_match).to be_truthy
      end
    end

    def add_remove_to_zero(opts = {})
      code = <<-RUBY_EVAL
        acc += 1 unless cache.put_if_absent(key, key)
        acc -= 1 if cache.delete_pair(key, key)
      RUBY_EVAL
      do_thread_loop(
        __method__, 
        code, 
        {loop_count: 5}.merge(opts)
      ) do |result, cache, options, keys|
        expect_all_key_mappings_exist(cache, keys, false)
        expect(cache.size).to eq sum(result)
      end
    end

    def add_remove_to_zero_via_merge_pair(opts = {})
      code = <<-RUBY_EVAL
        acc += (cache.merge_pair(key, key) {}) ? 1 : -1
      RUBY_EVAL
      do_thread_loop(
        __method__, 
        code, 
        {loop_count: 5}.merge(opts)
      ) do |result, cache, options, keys|
        expect_all_key_mappings_exist(cache, keys, false)
        expect(cache.size).to eq sum(result)
      end
    end

    def do_thread_loop(name, code, options = {}, &block)
      options = DEFAULTS.merge(options)
      meth    = define_loop(name, code, options[:prelude])
      keys    = to_keys_array(options[:key_count])
      run_thread_loop(meth, keys, options, &block)

      if options[:key_count] > 1
        options[:key_count] = (options[:key_count] / 40).to_i
        keys = to_hash_collision_keys_array(options[:key_count])
        run_thread_loop(
          meth, 
          keys, 
          options.merge(loop_count: options[:loop_count] * 5), 
          &block
        )
      end
    end

    def run_thread_loop(meth, keys, options, &block)
      cache   = options[:cache_setup].call(options, keys)
      barrier = ThreadSafe::Test::Barrier.new(options[:thread_count])
      result = (1..options[:thread_count]).map do
        Thread.new do
          setup_sync_and_start_loop(
            meth, 
            cache, 
            keys, 
            barrier, 
            options[:loop_count]
          )
        end
      end.map(&:value)
      block.call(result, cache, options, keys) if block_given?
    end

    def setup_sync_and_start_loop(meth, cache, keys, barrier, loop_count)
      my_keys = keys.shuffle
      barrier.await
      if my_keys.size == 1
        key = my_keys.first
        send("#{meth}_single_key", cache, key, loop_count)
      else
        send("#{meth}_multiple_keys", cache, my_keys, loop_count)
      end
    end

    def define_loop(name, body, prelude)
      inner_meth_name = :"_#{name}_loop_inner"
      outer_meth_name = :"_#{name}_loop_outer"
      # looping is splitted into the "loop methods" to trigger the JIT
      self.class.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{inner_meth_name}_multiple_keys(cache, keys, i, length, acc)
          #{prelude}
          target = i + length
          while i < target
            key = keys[i]
            #{body}
            i += 1
          end
          acc
        end unless method_defined?(:#{inner_meth_name}_multiple_keys)
      RUBY_EVAL

      self.class.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{inner_meth_name}_single_key(cache, key, i, length, acc)
          #{prelude}
          target = i + length
          while i < target
            #{body}
            i += 1
          end
          acc
        end unless method_defined?(:#{inner_meth_name}_single_key)
      RUBY_EVAL

      self.class.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{outer_meth_name}_multiple_keys(cache, keys, loop_count)
          total_length = keys.size
          acc = 0
          inc = 100
          loop_count.times do
            i = 0
            pre_loop_inc = total_length % inc
            acc = #{inner_meth_name}_multiple_keys(cache, keys, i, pre_loop_inc, acc)
            i += pre_loop_inc
            while i < total_length
              acc = #{inner_meth_name}_multiple_keys(cache, keys, i, inc, acc)
              i += inc
            end
          end
          acc
        end unless method_defined?(:#{outer_meth_name}_multiple_keys)
      RUBY_EVAL

      self.class.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{outer_meth_name}_single_key(cache, key, loop_count)
          acc = 0
          i   = 0
          inc = 100

          pre_loop_inc = loop_count % inc
          acc          = #{inner_meth_name}_single_key(cache, key, i, pre_loop_inc, acc)
          i += pre_loop_inc

          while i < loop_count
            acc = #{inner_meth_name}_single_key(cache, key, i, inc, acc)
            i += inc
          end
          acc
        end unless method_defined?(:#{outer_meth_name}_single_key)
      RUBY_EVAL
      outer_meth_name
    end

    def to_keys_array(key_count)
      arr = []
      key_count.times {|i| arr << i}
      arr
    end

    def to_hash_collision_keys_array(key_count)
      to_keys_array(key_count).map { |key| ThreadSafe::Test::HashCollisionKey(key) }
    end

    def sum(result)
      result.inject(0) { |acc, i| acc + i }
    end

    def expect_standard_accumulator_test_result(result, cache, options, keys)
      expect_all_key_mappings_exist(cache, keys)
      expect(options[:key_count]).to eq sum(result)
      expect(options[:key_count]).to eq cache.size
    end

    def expect_all_key_mappings_exist(cache, keys, all_must_exist = true)
      keys.each do |key|
        value = cache[key]
        if value || all_must_exist
          expect(key).to eq value unless key == value # don't do a bazzilion assertions unless necessary
        end
      end
    end

    def expect_count_up(result, cache, options, keys)
      keys.each do |key|
        value = cache[key]
        expect(value).to be_truthy unless value
      end
      expect(sum(cache.values)).to   eq sum(result)
      expect(options[:key_count]).to eq cache.size
    end
  end unless RUBY_ENGINE == 'rbx' || ENV['TRAVIS']
end