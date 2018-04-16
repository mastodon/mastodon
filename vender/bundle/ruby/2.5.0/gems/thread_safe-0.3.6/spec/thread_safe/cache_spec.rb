Thread.abort_on_exception = true

module ThreadSafe
  describe Cache do
    before(:each) do
      @cache = described_class.new
    end

    it 'concurrency' do
      (1..THREADS).map do |i|
        Thread.new do
          1000.times do |j|
            key = i * 1000 + j
            @cache[key] = i
            @cache[key]
            @cache.delete(key)
          end
        end
      end.map(&:join)
    end

    it 'retrieval' do
      expect_size_change(1) do
        expect(nil).to eq @cache[:a]
        expect(nil).to eq @cache.get(:a)
        @cache[:a] = 1
        expect(1).to   eq @cache[:a]
        expect(1).to   eq @cache.get(:a)
      end
    end

    it '#put_if_absent' do
      with_or_without_default_proc do
        expect_size_change(1) do
          expect(nil).to eq @cache.put_if_absent(:a, 1)
          expect(1).to   eq @cache.put_if_absent(:a, 1)
          expect(1).to   eq @cache.put_if_absent(:a, 2)
          expect(1).to   eq @cache[:a]
        end
      end
    end

    describe '#compute_if_absent' do
      it 'common' do
        with_or_without_default_proc do
          expect_size_change(3) do
            expect(1).to eq @cache.compute_if_absent(:a) { 1 }
            expect(1).to eq @cache.compute_if_absent(:a) { 2 }
            expect(1).to eq @cache[:a]

            @cache[:b] = nil
            expect(nil).to  eq @cache.compute_if_absent(:b) { 1 }
            expect(nil).to  eq @cache.compute_if_absent(:c) {}
            expect(nil).to  eq @cache[:c]
            expect(true).to eq @cache.key?(:c)
          end
        end
      end

      it 'with return' do
        with_or_without_default_proc do
          expect_handles_return_lambda(:compute_if_absent, :a)
        end
      end

      it 'exception' do
        with_or_without_default_proc do
          expect_handles_exception(:compute_if_absent, :a)
        end
      end

      it 'atomicity' do
        late_compute_threads_count       = 10
        late_put_if_absent_threads_count = 10
        getter_threads_count             = 5
        compute_started = ThreadSafe::Test::Latch.new(1)
        compute_proceed = ThreadSafe::Test::Latch.new(
          late_compute_threads_count + 
          late_put_if_absent_threads_count + 
          getter_threads_count
        )
        block_until_compute_started = lambda do |name|
          # what does it mean?
          if (v = @cache[:a]) != nil
            expect(nil).to v
          end
          compute_proceed.release
          compute_started.await
        end

        expect_size_change 1 do
          late_compute_threads = Array.new(late_compute_threads_count) do
            Thread.new do
              block_until_compute_started.call('compute_if_absent')
              expect(1).to eq @cache.compute_if_absent(:a) { fail }
            end
          end

          late_put_if_absent_threads = Array.new(late_put_if_absent_threads_count) do
            Thread.new do
              block_until_compute_started.call('put_if_absent')
              expect(1).to eq @cache.put_if_absent(:a, 2)
            end
          end

          getter_threads = Array.new(getter_threads_count) do
            Thread.new do
              block_until_compute_started.call('getter')
              Thread.pass while @cache[:a].nil?
              expect(1).to eq @cache[:a]
            end
          end

          Thread.new do
            @cache.compute_if_absent(:a) do
              compute_started.release
              compute_proceed.await
              sleep(0.2)
              1
            end
          end.join
          (late_compute_threads + 
           late_put_if_absent_threads + 
           getter_threads).each(&:join)
        end
      end
    end

    describe '#compute_if_present' do
      it 'common' do
        with_or_without_default_proc do
          expect_no_size_change do
            expect(nil).to   eq @cache.compute_if_present(:a) {}
            expect(nil).to   eq @cache.compute_if_present(:a) { 1 }
            expect(nil).to   eq @cache.compute_if_present(:a) { fail }
            expect(false).to eq @cache.key?(:a)
          end

          @cache[:a] = 1
          expect_no_size_change do
            expect(1).to     eq @cache.compute_if_present(:a) { 1 }
            expect(1).to     eq @cache[:a]
            expect(2).to     eq @cache.compute_if_present(:a) { 2 }
            expect(2).to     eq @cache[:a]
            expect(false).to eq @cache.compute_if_present(:a) { false }
            expect(false).to eq @cache[:a]

            @cache[:a] = 1
            yielded    = false
            @cache.compute_if_present(:a) do |old_value|
              yielded = true
              expect(1).to eq old_value
              2
            end
            expect(true).to eq yielded
          end

          expect_size_change(-1) do
            expect(nil).to   eq @cache.compute_if_present(:a) {}
            expect(false).to eq @cache.key?(:a)
            expect(nil).to   eq @cache.compute_if_present(:a) { 1 }
            expect(false).to eq @cache.key?(:a)
          end
        end
      end

      it 'with return' do
        with_or_without_default_proc do
          @cache[:a] = 1
          expect_handles_return_lambda(:compute_if_present, :a) 
        end
      end

      it 'exception' do
        with_or_without_default_proc do
          @cache[:a] = 1
          expect_handles_exception(:compute_if_present, :a)
        end
      end
    end

    describe '#compute' do
      it 'common' do
        with_or_without_default_proc do
          expect_no_size_change do
            expect_compute(:a, nil, nil) {}
          end

          expect_size_change(1) do
            expect_compute(:a, nil, 1)   { 1 }
            expect_compute(:a, 1,   2)   { 2 }
            expect_compute(:a, 2, false) { false }
            expect(false).to eq @cache[:a]
          end

          expect_size_change(-1) do
            expect_compute(:a, false, nil) {}
          end
        end
      end

      it 'with return' do
        with_or_without_default_proc do
          expect_handles_return_lambda(:compute, :a)
          @cache[:a] = 1
          expect_handles_return_lambda(:compute, :a)
        end
      end

      it 'exception' do
        with_or_without_default_proc do
          expect_handles_exception(:compute, :a)
          @cache[:a] = 2
          expect_handles_exception(:compute, :a)
        end
      end
    end

    describe '#merge_pair' do
      it 'common' do
        with_or_without_default_proc do
          expect_size_change(1) do
            expect(nil).to  eq @cache.merge_pair(:a, nil) { fail }
            expect(true).to eq @cache.key?(:a)
            expect(nil).to  eq @cache[:a]
          end

          expect_no_size_change do
            expect_merge_pair(:a, nil, nil,   false) { false }
            expect_merge_pair(:a, nil, false, 1)     { 1 }
            expect_merge_pair(:a, nil, 1,     2)     { 2 }
          end

          expect_size_change(-1) do
            expect_merge_pair(:a, nil, 2, nil) {}
            expect(false).to eq @cache.key?(:a)
          end
        end
      end

      it 'with return' do
        with_or_without_default_proc do
          @cache[:a] = 1
          expect_handles_return_lambda(:merge_pair, :a, 2)
        end
      end

      it 'exception' do
        with_or_without_default_proc do
          @cache[:a] = 1
          expect_handles_exception(:merge_pair, :a, 2)
        end
      end
    end

    it 'updates dont block reads' do
      getters_count = 20
      key_klass     = ThreadSafe::Test::HashCollisionKey
      keys          = [key_klass.new(1, 100), 
                       key_klass.new(2, 100), 
                       key_klass.new(3, 100)] # hash colliding keys
      inserted_keys = []

      keys.each do |key, i|
        compute_started  = ThreadSafe::Test::Latch.new(1)
        compute_finished = ThreadSafe::Test::Latch.new(1)
        getters_started  = ThreadSafe::Test::Latch.new(getters_count)
        getters_finished = ThreadSafe::Test::Latch.new(getters_count)

        computer_thread = Thread.new do
          getters_started.await
          @cache.compute_if_absent(key) do
            compute_started.release
            getters_finished.await
            1
          end
          compute_finished.release
        end

        getter_threads = (1..getters_count).map do
          Thread.new do
            getters_started.release
            inserted_keys.each do |inserted_key|
              expect(true).to eq @cache.key?(inserted_key)
              expect(1).to    eq @cache[inserted_key]
            end
            expect(false).to eq @cache.key?(key)
            compute_started.await
            inserted_keys.each do |inserted_key|
              expect(true).to eq @cache.key?(inserted_key)
              expect(1).to    eq @cache[inserted_key]
            end
            expect(false).to eq @cache.key?(key)
            expect(nil).to   eq @cache[key]
            getters_finished.release
            compute_finished.await
            expect(true).to eq @cache.key?(key)
            expect(1).to    eq @cache[key]
          end
        end

        (getter_threads << computer_thread).map do |t| 
          expect(t.join(2)).to be_truthy
        end # asserting no deadlocks
        inserted_keys << key
      end
    end

    specify 'collision resistance' do
      expect_collision_resistance(
        (0..1000).map { |i| ThreadSafe::Test::HashCollisionKey(i, 1) }
      )
    end

    specify 'collision resistance with arrays' do
      special_array_class = Class.new(Array) do
        def key # assert_collision_resistance expects to be able to call .key to get the "real" key
          first.key
        end
      end
      # Test collision resistance with a keys that say they responds_to <=>, but then raise exceptions
      # when actually called (ie: an Array filled with non-comparable keys).
      # See https://github.com/headius/thread_safe/issues/19 for more info.
      expect_collision_resistance(
        (0..100).map do |i|
          special_array_class.new(
            [ThreadSafe::Test::HashCollisionKeyNonComparable.new(i, 1)]
          )
        end
      )
    end

    it '#replace_pair' do
      with_or_without_default_proc do
        expect_no_size_change do
          expect(false).to eq @cache.replace_pair(:a, 1, 2)
          expect(false).to eq @cache.replace_pair(:a, nil, nil)
          expect(false).to eq @cache.key?(:a)
        end
      end

      @cache[:a] = 1
      expect_no_size_change do
        expect(true).to  eq @cache.replace_pair(:a, 1, 2)
        expect(false).to eq @cache.replace_pair(:a, 1, 2)
        expect(2).to     eq @cache[:a]
        expect(true).to  eq @cache.replace_pair(:a, 2, 2)
        expect(2).to     eq @cache[:a]
        expect(true).to  eq @cache.replace_pair(:a, 2, nil)
        expect(false).to eq @cache.replace_pair(:a, 2, nil)
        expect(nil).to   eq @cache[:a]
        expect(true).to  eq @cache.key?(:a)
        expect(true).to  eq @cache.replace_pair(:a, nil, nil)
        expect(true).to  eq @cache.key?(:a)
        expect(true).to  eq @cache.replace_pair(:a, nil, 1)
        expect(1).to     eq @cache[:a]
      end
    end

    it '#replace_if_exists' do
      with_or_without_default_proc do
        expect_no_size_change do
          expect(nil).to   eq @cache.replace_if_exists(:a, 1)
          expect(false).to eq @cache.key?(:a)
        end

        @cache[:a] = 1
        expect_no_size_change do
          expect(1).to    eq  @cache.replace_if_exists(:a, 2)
          expect(2).to    eq  @cache[:a]
          expect(2).to    eq  @cache.replace_if_exists(:a, nil)
          expect(nil).to  eq  @cache[:a]
          expect(true).to eq  @cache.key?(:a)
          expect(nil).to  eq  @cache.replace_if_exists(:a, 1)
          expect(1).to    eq  @cache[:a]
        end
      end
    end

    it '#get_and_set' do
      with_or_without_default_proc do
        expect(nil).to  eq  @cache.get_and_set(:a, 1)
        expect(true).to eq  @cache.key?(:a)
        expect(1).to    eq  @cache[:a]
        expect(1).to    eq  @cache.get_and_set(:a, 2)
        expect(2).to    eq  @cache.get_and_set(:a, nil)
        expect(nil).to  eq  @cache[:a]
        expect(true).to eq  @cache.key?(:a)
        expect(nil).to  eq  @cache.get_and_set(:a, 1)
        expect(1).to    eq  @cache[:a]
      end
    end

    it '#key' do
      with_or_without_default_proc do
        expect(nil).to eq @cache.key(1)
        @cache[:a] = 1
        expect(:a).to  eq  @cache.key(1)
        expect(nil).to eq  @cache.key(0)
      end
    end

    it '#key?' do
      with_or_without_default_proc do
        expect(false).to eq @cache.key?(:a)
        @cache[:a] = 1
        expect(true).to  eq @cache.key?(:a)
      end
    end

    it '#value?' do
      with_or_without_default_proc do
        expect(false).to eq @cache.value?(1)
        @cache[:a] = 1
        expect(true).to  eq @cache.value?(1)
      end
    end

    it '#delete' do
      with_or_without_default_proc do |default_proc_set|
        expect_no_size_change do
          expect(nil).to   eq @cache.delete(:a)
        end
        @cache[:a] = 1
        expect_size_change -1 do
          expect(1).to     eq @cache.delete(:a)
        end
        expect_no_size_change do
          expect(nil).to   eq @cache[:a] unless default_proc_set

          expect(false).to eq @cache.key?(:a)
          expect(nil).to   eq @cache.delete(:a)
        end
      end
    end

    it '#delete_pair' do
      with_or_without_default_proc do
        expect_no_size_change do
          expect(false).to eq @cache.delete_pair(:a, 2)
          expect(false).to eq @cache.delete_pair(:a, nil)
        end
        @cache[:a] = 1
        expect_no_size_change do
          expect(false).to eq @cache.delete_pair(:a, 2)
        end
        expect_size_change(-1) do
          expect(1).to     eq @cache[:a]
          expect(true).to  eq @cache.delete_pair(:a, 1)
          expect(false).to eq @cache.delete_pair(:a, 1)
          expect(false).to eq @cache.key?(:a)
        end
      end
    end

    specify 'default proc' do
      @cache = cache_with_default_proc(1)
      expect_no_size_change do
        expect(false).to eq @cache.key?(:a)
      end
      expect_size_change(1) do
        expect(1).to     eq @cache[:a]
        expect(true).to  eq @cache.key?(:a)
      end
    end

    specify 'falsy default proc' do
      @cache = cache_with_default_proc(nil)
      expect_no_size_change do
        expect(false).to eq @cache.key?(:a)
      end
      expect_size_change(1) do
        expect(nil).to   eq @cache[:a]
        expect(true).to  eq @cache.key?(:a)
      end
    end

    describe '#fetch' do
      it 'common' do
        with_or_without_default_proc do |default_proc_set| 
          expect_no_size_change do 
            expect(1).to     eq @cache.fetch(:a, 1)
            expect(1).to     eq @cache.fetch(:a) { 1 }
            expect(false).to eq @cache.key?(:a)

            expect(nil).to   eq @cache[:a] unless default_proc_set
          end

          @cache[:a] = 1
          expect_no_size_change do
            expect(1).to eq @cache.fetch(:a) { fail }
          end

          expect { @cache.fetch(:b) }.to raise_error(KeyError)

          expect_no_size_change do
            expect(1).to     eq @cache.fetch(:b, :c) {1} # assert block supersedes default value argument
            expect(false).to eq @cache.key?(:b)
          end
        end
      end

      it 'falsy' do
        with_or_without_default_proc do
          expect(false).to eq @cache.key?(:a)

          expect_no_size_change do
            expect(nil).to   eq @cache.fetch(:a, nil)
            expect(false).to eq @cache.fetch(:a, false)
            expect(nil).to   eq @cache.fetch(:a) {}
            expect(false).to eq @cache.fetch(:a) { false }
          end

          @cache[:a] = nil
          expect_no_size_change do
            expect(true).to eq @cache.key?(:a)
            expect(nil).to  eq @cache.fetch(:a) { fail }
          end
        end
      end

      it 'with return' do
        with_or_without_default_proc do
          r = fetch_with_return
          # r = lambda do
          #   @cache.fetch(:a) { return 10 }
          # end.call

          expect_no_size_change do
            expect(10).to    eq r
            expect(false).to eq @cache.key?(:a)
          end
        end
      end
    end

    describe '#fetch_or_store' do
      it 'common' do
        with_or_without_default_proc do |default_proc_set|
          expect_size_change(1) do
            expect(1).to eq @cache.fetch_or_store(:a, 1)
            expect(1).to eq @cache[:a]
          end

          @cache.delete(:a)

          expect_size_change 1 do
            expect(1).to eq @cache.fetch_or_store(:a) { 1 }
            expect(1).to eq @cache[:a]
          end

          expect_no_size_change do
            expect(1).to eq @cache.fetch_or_store(:a) { fail }
          end

          expect { @cache.fetch_or_store(:b) }.
            to raise_error(KeyError)

          expect_size_change(1) do
            expect(1).to eq @cache.fetch_or_store(:b, :c) { 1 } # assert block supersedes default value argument
            expect(1).to eq @cache[:b]
          end
        end
      end

      it 'falsy' do
        with_or_without_default_proc do
          expect(false).to eq @cache.key?(:a)

          expect_size_change(1) do
            expect(nil).to  eq @cache.fetch_or_store(:a, nil)
            expect(nil).to  eq @cache[:a]
            expect(true).to eq @cache.key?(:a)
          end
          @cache.delete(:a)

          expect_size_change(1) do
            expect(false).to eq @cache.fetch_or_store(:a, false)
            expect(false).to eq @cache[:a]
            expect(true).to  eq @cache.key?(:a)
          end
          @cache.delete(:a)

          expect_size_change(1) do
            expect(nil).to  eq @cache.fetch_or_store(:a) {}
            expect(nil).to  eq @cache[:a]
            expect(true).to eq @cache.key?(:a)
          end
          @cache.delete(:a)

          expect_size_change(1) do
            expect(false).to eq @cache.fetch_or_store(:a) { false }
            expect(false).to eq @cache[:a]
            expect(true).to  eq @cache.key?(:a)
          end

          @cache[:a] = nil
          expect_no_size_change do
            expect(nil).to eq @cache.fetch_or_store(:a) { fail }
          end
        end
      end

      it 'with return' do
        with_or_without_default_proc do
          r = fetch_or_store_with_return

          expect_no_size_change do
            expect(10).to    eq r
            expect(false).to eq @cache.key?(:a)
          end
        end
      end
    end

    it '#clear' do
      @cache[:a] = 1
      expect_size_change(-1) do
        expect(@cache).to eq @cache.clear
        expect(false).to  eq @cache.key?(:a)
        expect(nil).to    eq @cache[:a]
      end
    end

    describe '#each_pair' do
      it 'common' do
        @cache.each_pair { |k, v| fail }
        expect(@cache).to eq @cache.each_pair {}
        @cache[:a] = 1

        h = {}
        @cache.each_pair { |k, v| h[k] = v }
        expect({:a => 1}).to eq h

        @cache[:b] = 2
        h = {}
        @cache.each_pair { |k, v| h[k] = v }
        expect({:a => 1, :b => 2}).to eq h
      end

      it 'pair iterator' do
        @cache[:a] = 1
        @cache[:b] = 2
        i = 0
        r = @cache.each_pair do |k, v|
          if i == 0
            i += 1
            next
            fail
          elsif i == 1
            break :breaked
          end
        end

        expect(:breaked).to eq r
      end

      it 'allows modification' do
        @cache[:a] = 1
        @cache[:b] = 1
        @cache[:c] = 1

        expect_size_change(1) do
          @cache.each_pair do |k, v|
            @cache[:z] = 1
          end
        end
      end
    end

    it '#keys' do
      expect([]).to eq @cache.keys

      @cache[1] = 1
      expect([1]).to eq @cache.keys

      @cache[2] = 2
      expect([1, 2]).to eq @cache.keys.sort
    end

    it '#values' do
      expect([]).to eq @cache.values

      @cache[1] = 1
      expect([1]).to eq @cache.values

      @cache[2] = 2
      expect([1, 2]).to eq @cache.values.sort
    end

    it '#each_key' do
      expect(@cache).to eq @cache.each_key { fail }

      @cache[1] = 1
      arr = []
      @cache.each_key { |k| arr << k }
      expect([1]).to eq arr

      @cache[2] = 2
      arr = []
      @cache.each_key { |k| arr << k }
      expect([1, 2]).to eq arr.sort
    end

    it '#each_value' do
      expect(@cache).to eq @cache.each_value { fail }

      @cache[1] = 1
      arr = []
      @cache.each_value { |k| arr << k }
      expect([1]).to eq arr

      @cache[2] = 2
      arr = []
      @cache.each_value { |k| arr << k }
      expect([1, 2]).to eq arr.sort
    end

    it '#empty' do
      expect(true).to  eq @cache.empty?
      @cache[:a] = 1
      expect(false).to eq @cache.empty?
    end

    it 'options validation' do
      expect_valid_options(nil)
      expect_valid_options({})
      expect_valid_options(foo: :bar)
    end

    it 'initial capacity options validation' do
      expect_valid_option(:initial_capacity, nil)
      expect_valid_option(:initial_capacity, 1)
      expect_invalid_option(:initial_capacity, '')
      expect_invalid_option(:initial_capacity, 1.0)
      expect_invalid_option(:initial_capacity, -1)
    end

    it 'load factor options validation' do
      expect_valid_option(:load_factor, nil)
      expect_valid_option(:load_factor, 0.01)
      expect_valid_option(:load_factor, 0.75)
      expect_valid_option(:load_factor, 1)
      expect_invalid_option(:load_factor, '')
      expect_invalid_option(:load_factor, 0)
      expect_invalid_option(:load_factor, 1.1)
      expect_invalid_option(:load_factor, 2)
      expect_invalid_option(:load_factor, -1)
    end

    it '#size' do
      expect(0).to eq @cache.size
      @cache[:a] = 1
      expect(1).to eq @cache.size
      @cache[:b] = 1
      expect(2).to eq @cache.size
      @cache.delete(:a)
      expect(1).to eq @cache.size
      @cache.delete(:b)
      expect(0).to eq @cache.size
    end

    it '#get_or_default' do
      with_or_without_default_proc do
        expect(1).to     eq @cache.get_or_default(:a, 1)
        expect(nil).to   eq @cache.get_or_default(:a, nil)
        expect(false).to eq @cache.get_or_default(:a, false)
        expect(false).to eq @cache.key?(:a)

        @cache[:a] = 1
        expect(1).to eq @cache.get_or_default(:a, 2)
      end
    end

    it '#dup,#clone' do
      [:dup, :clone].each do |meth|
        cache = cache_with_default_proc(:default_value)
        cache[:a] = 1
        dupped = cache.send(meth)
        expect(1).to eq dupped[:a]
        expect(1).to eq dupped.size
        expect_size_change(1, cache) do
          expect_no_size_change(dupped) do
            cache[:b] = 1
          end
        end
        expect(false).to eq dupped.key?(:b)
        expect_no_size_change(cache) do
          expect_size_change(-1, dupped) do
            dupped.delete(:a)
          end
        end
        expect(false).to eq dupped.key?(:a)
        expect(true).to  eq cache.key?(:a)
        # test default proc
        expect_size_change(1, cache) do
          expect_no_size_change dupped do
            expect(:default_value).to eq cache[:c]
            expect(false).to          eq dupped.key?(:c)
          end
        end
        expect_no_size_change cache do
          expect_size_change 1, dupped do
            expect(:default_value).to eq dupped[:d]
            expect(false).to          eq cache.key?(:d)
          end
        end
      end
    end

    it 'is unfreezable' do
      expect { @cache.freeze }.to raise_error(NoMethodError)
    end

    it 'marshal dump load' do
      new_cache = Marshal.load(Marshal.dump(@cache))
      expect(new_cache).to be_an_instance_of ThreadSafe::Cache
      expect(0).to eq new_cache.size
      @cache[:a] = 1
      new_cache = Marshal.load(Marshal.dump(@cache))
      expect(1).to eq @cache[:a]
      expect(1).to eq new_cache.size
    end

    it 'marshal dump doesnt work with default proc' do
      expect { Marshal.dump(ThreadSafe::Cache.new {}) }.to raise_error(TypeError)
    end

    private

    def with_or_without_default_proc(&block)
      block.call(false)
      @cache = ThreadSafe::Cache.new { |h, k| h[k] = :default_value }
      block.call(true)
    end

    def cache_with_default_proc(default_value = 1)
      ThreadSafe::Cache.new { |cache, k| cache[k] = default_value }
    end

    def expect_size_change(change, cache = @cache, &block)
      start = cache.size
      block.call
      expect(change).to eq cache.size - start
    end

    def expect_valid_option(option_name, value)
      expect_valid_options(option_name => value)
    end

    def expect_valid_options(options)
      c = ThreadSafe::Cache.new(options)
      expect(c).to be_an_instance_of ThreadSafe::Cache
    end

    def expect_invalid_option(option_name, value)
      expect_invalid_options(option_name => value)
    end

    def expect_invalid_options(options)
      expect { ThreadSafe::Cache.new(options) }.to raise_error(ArgumentError)
    end

    def expect_no_size_change(cache = @cache, &block) 
      expect_size_change(0, cache, &block)
    end

    def expect_handles_return_lambda(method, key, *args)
      before_had_key   = @cache.key?(key)
      before_had_value = before_had_key ? @cache[key] : nil

      returning_lambda = lambda do
        @cache.send(method, key, *args) { return :direct_return }
      end

      expect_no_size_change do
        expect(:direct_return).to   eq returning_lambda.call
        expect(before_had_key).to   eq @cache.key?(key)
        expect(before_had_value).to eq @cache[key] if before_had_value
      end
    end

    class TestException < Exception; end
    def expect_handles_exception(method, key, *args)
      before_had_key   = @cache.key?(key)
      before_had_value = before_had_key ? @cache[key] : nil

      expect_no_size_change do
        expect { @cache.send(method, key, *args) { raise TestException, '' } }.
          to raise_error(TestException)

        expect(before_had_key).to   eq @cache.key?(key)
        expect(before_had_value).to eq @cache[key] if before_had_value
      end
    end

    def expect_compute(key, expected_old_value, expected_result, &block)
      result = @cache.compute(:a) do |old_value|
        expect(expected_old_value).to eq old_value
        block.call
      end
      expect(expected_result).to eq result
    end

    def expect_merge_pair(key, value, expected_old_value, expected_result, &block)
      result = @cache.merge_pair(key, value) do |old_value|
        expect(expected_old_value).to eq old_value
        block.call
      end
      expect(expected_result).to eq result
    end

    def expect_collision_resistance(keys)
      keys.each { |k| @cache[k] = k.key }
      10.times do |i|
        size = keys.size
        while i < size
          k = keys[i]
          expect(k.key == @cache.delete(k) && 
                 !@cache.key?(k) && 
                 (@cache[k] = k.key; @cache[k] == k.key)).to be_truthy
          i += 10
        end
      end
      expect(keys.all? { |k| @cache[k] == k.key }).to be_truthy
    end

    # Took out for compatibility with Rubinius, see https://github.com/rubinius/rubinius/issues/1312
    def fetch_with_return
      lambda do
        @cache.fetch(:a) { return 10 }
      end.call
    end

    # Took out for compatibility with Rubinius, see https://github.com/rubinius/rubinius/issues/1312
    def fetch_or_store_with_return
      lambda do
        @cache.fetch_or_store(:a) { return 10 }
      end.call
    end

  end
end
