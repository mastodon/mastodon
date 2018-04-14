def model_tests(collection, params = {}, mocks_implemented = true)
  tests('success') do

    @instance = collection.new(params)

    tests("#save").succeeds do
      pending if Fog.mocking? && !mocks_implemented
      @instance.save
    end

    if block_given?
      yield(@instance)
    end

    tests("#destroy").succeeds do
      pending if Fog.mocking? && !mocks_implemented
      @instance.destroy
    end

  end
end

# Generates a unique identifier with a random differentiator.
# Useful when rapidly re-running tests, so we don't have to wait
# serveral minutes for deleted objects to disappear from the API
# E.g. 'fog-test-1234'
def uniq_id(base_name = 'fog-test')
  # random_differentiator
  suffix = rand(65536).to_s(16).rjust(4, '0')
  [base_name, suffix] * '-'
end
