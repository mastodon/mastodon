def collection_tests(collection, params = {}, mocks_implemented = true)
  tests("success") do
    tests("#new(#{params.inspect})").succeeds do
      pending if Fog.mocking? && !mocks_implemented
      collection.new(params)
    end

    tests("#create(#{params.inspect})").succeeds do
      pending if Fog.mocking? && !mocks_implemented
      @instance = collection.create(params)
    end

    # FIXME: work around for timing issue on AWS describe_instances mocks
    if Fog.mocking? && @instance.respond_to?(:ready?)
      @instance.wait_for { ready? }
    end

    tests("#all").succeeds do
      pending if Fog.mocking? && !mocks_implemented
      collection.all
    end

    @identity = @instance.identity if !Fog.mocking? || mocks_implemented

    tests("#get(#{@identity})").succeeds do
      pending if Fog.mocking? && !mocks_implemented
      collection.get(@identity)
    end

    tests("Enumerable") do
      pending if Fog.mocking? && !mocks_implemented

      methods = %w(all? any? find detect collect map find_index flat_map
                   collect_concat group_by none? one?)

      # JRuby 1.7.5+ issue causes a SystemStackError: stack level too deep
      # https://github.com/jruby/jruby/issues/1265
      if RUBY_PLATFORM == "java" && JRUBY_VERSION =~ /1\.7\.[5-8]/
        methods.delete("all?")
      end

      methods.each do |enum_method|
        next unless collection.respond_to?(enum_method)
        tests("##{enum_method}").succeeds do
          block_called = false
          collection.send(enum_method) { block_called = true }
          block_called
        end
      end

      %w(max_by min_by).each do |enum_method|
        next unless collection.respond_to?(enum_method)
        tests("##{enum_method}").succeeds do
          block_called = false
          collection.send(enum_method) do
            block_called = true
            0
          end
          block_called
        end
      end
    end

    yield if block_given?

    @instance.destroy if !Fog.mocking? || mocks_implemented
  end

  tests("failure") do
    if !Fog.mocking? || mocks_implemented
      @identity = @identity.to_s
      @identity = @identity.gsub(/[a-zA-Z]/) { Fog::Mock.random_letters(1) }
      @identity = @identity.gsub(/\d/)       { Fog::Mock.random_numbers(1) }
      @identity
    end

    tests("#get('#{@identity}')").returns(nil) do
      pending if Fog.mocking? && !mocks_implemented
      collection.get(@identity)
    end
  end
end
