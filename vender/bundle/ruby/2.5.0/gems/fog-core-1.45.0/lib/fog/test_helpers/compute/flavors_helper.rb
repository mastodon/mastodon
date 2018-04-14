def flavors_tests(connection, _params = {}, mocks_implemented = true)
  tests("success") do
    tests("#all").succeeds do
      pending if Fog.mocking? && !mocks_implemented
      connection.flavors.all
    end

    if !Fog.mocking? || mocks_implemented
      @identity = connection.flavors.first.identity
    end

    tests("#get('#{@identity}')").succeeds do
      pending if Fog.mocking? && !mocks_implemented
      connection.flavors.get(@identity)
    end
  end

  tests("failure") do
    if !Fog.mocking? || mocks_implemented
      invalid_flavor_identity = connection.flavors.first.identity.to_s.gsub(/\w/, "0")
    end

    tests("#get('#{invalid_flavor_identity}')").returns(nil) do
      pending if Fog.mocking? && !mocks_implemented
      connection.flavors.get(invalid_flavor_identity)
    end
  end
end
