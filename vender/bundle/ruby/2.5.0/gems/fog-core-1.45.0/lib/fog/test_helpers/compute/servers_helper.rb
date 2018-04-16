def servers_tests(connection, params = {}, mocks_implemented = true)
  collection_tests(connection.servers, params, mocks_implemented) do
    if !Fog.mocking? || mocks_implemented
      @instance.wait_for { ready? }
      yield if block_given?
    end
  end
end
