Shindo.tests('Excon request idempotencey') do

  before do
    @connection = Excon.new('http://127.0.0.1:9292', :mock => true)
  end

  after do
    # flush any existing stubs after each test
    Excon.stubs.clear
  end

  tests("Non-idempotent call with an erroring socket").raises(Excon::Errors::SocketError) do
    run_count = 0
    Excon.stub({:method => :get}) { |params|
      run_count += 1
      if run_count <= 3 # First 3 calls fail.
        raise Excon::Errors::SocketError.new(Exception.new "Mock Error")
      else
        {:body => params[:body], :headers => params[:headers], :status => 200}
      end
    }

    @connection.request(:method => :get, :path => '/some-path')
  end

  tests("Idempotent request with socket erroring first 3 times").returns(200) do
    run_count = 0
    Excon.stub({:method => :get}) { |params|
      run_count += 1
      if run_count <= 3 # First 3 calls fail.
        raise Excon::Errors::SocketError.new(Exception.new "Mock Error")
      else
        {:body => params[:body], :headers => params[:headers], :status => 200}
      end
    }

    response = @connection.request(:method => :get, :idempotent => true, :path => '/some-path')
    response.status
  end

  tests("Idempotent request with socket erroring first 5 times").raises(Excon::Errors::SocketError) do
    run_count = 0
    Excon.stub({:method => :get}) { |params|
      run_count += 1
      if run_count <= 5 # First 5 calls fail.
        raise Excon::Errors::SocketError.new(Exception.new "Mock Error")
      else
        {:body => params[:body], :headers => params[:headers], :status => 200}
      end
    }

    response = @connection.request(:method => :get, :idempotent => true, :path => '/some-path')
    response.status
  end

  tests("Lowered retry limit with socket erroring first time").returns(200) do
    run_count = 0
    Excon.stub({:method => :get}) { |params|
      run_count += 1
      if run_count <= 1 # First call fails.
        raise Excon::Errors::SocketError.new(Exception.new "Mock Error")
      else
        {:body => params[:body], :headers => params[:headers], :status => 200}
      end
    }

    response = @connection.request(:method => :get, :idempotent => true, :path => '/some-path', :retry_limit => 2)
    response.status
  end

  tests("Lowered retry limit with socket erroring first 3 times").raises(Excon::Errors::SocketError) do
    run_count = 0
    Excon.stub({:method => :get}) { |params|
      run_count += 1
      if run_count <= 3 # First 3 calls fail.
        raise Excon::Errors::SocketError.new(Exception.new "Mock Error")
      else
        {:body => params[:body], :headers => params[:headers], :status => 200}
      end
    }

    response = @connection.request(:method => :get, :idempotent => true, :path => '/some-path', :retry_limit => 2)
    response.status
  end

  tests("Raised retry limit with socket erroring first 5 times").returns(200) do
    run_count = 0
    Excon.stub({:method => :get}) { |params|
      run_count += 1
      if run_count <= 5 # First 5 calls fail.
        raise Excon::Errors::SocketError.new(Exception.new "Mock Error")
      else
        {:body => params[:body], :headers => params[:headers], :status => 200}
      end
    }

    response = @connection.request(:method => :get, :idempotent => true, :path => '/some-path', :retry_limit => 8)
    response.status
  end

  tests("Raised retry limit with socket erroring first 9 times").raises(Excon::Errors::SocketError) do
    run_count = 0
    Excon.stub({:method => :get}) { |params|
      run_count += 1
      if run_count <= 9 # First 9 calls fail.
        raise Excon::Errors::SocketError.new(Exception.new "Mock Error")
      else
        {:body => params[:body], :headers => params[:headers], :status => 200}
      end
    }

    response = @connection.request(:method => :get, :idempotent => true, :path => '/some-path', :retry_limit => 8)
    response.status
  end

  tests("Retry limit in constructor with socket erroring first 5 times").returns(200) do
    run_count = 0
    Excon.stub({:method => :get}) { |params|
      run_count += 1
      if run_count <= 5 # First 5 calls fail.
        raise Excon::Errors::SocketError.new(Exception.new "Mock Error")
      else
        {:body => params[:body], :headers => params[:headers], :status => 200}
      end
    }

    response = @connection.request(:method => :get, :idempotent => true, :path => '/some-path', :retry_limit => 6)
    response.status
  end

  tests("Retry limit and sleep in constructor with socket erroring first 2 times").returns(200) do
    run_count = 0
    Excon.stub({:method => :get}) { |params|
      run_count += 1
      if run_count <= 2 # First 5 calls fail.
        raise Excon::Errors::SocketError.new(Exception.new "Mock Error")
      else
        {:body => params[:body], :headers => params[:headers], :status => 200}
      end
    }


    # NOTE: A short :retry_interval will avoid slowing down the tests.
    response = @connection.request(:method => :get, :idempotent => true, :path => '/some-path', :retry_limit => 3, :retry_interval => 0.1)
    response.status
  end

  tests("Retry limit and sleep in constructor with socket erroring first 2 times").raises(Excon::Errors::SocketError) do
    run_count = 0
    Excon.stub({:method => :get}) { |params|
      run_count += 1
      if run_count <= 2 # First 5 calls fail.
        raise Excon::Errors::SocketError.new(Exception.new "Mock Error")
      else
        {:body => params[:body], :headers => params[:headers], :status => 200}
      end
    }

    # NOTE: A short :retry_interval will avoid slowing down the tests.
    response = @connection.request(:method => :get, :idempotent => true, :path => '/some-path', :retry_limit => 2, :retry_interval => 0.1)
    response.status
  end

  class Block
    attr_reader :rewound
    def initialize
      @rewound = false
    end
    def call(_)
    end
    def rewind
      @rewound = true
    end
  end

  tests("request_block rewound").returns(true) do
    run_count = 0
    Excon.stub({:method => :get}) { |params|
      run_count += 1
      if run_count <= 1 # First call fails.
        raise Excon::Errors::SocketError.new(Exception.new "Mock Error")
      else
        {:body => params[:body], :headers => params[:headers], :status => 200}
      end
    }
    request_block = Block.new
    @connection.request(:method => :get, :idempotent => true, :path => '/some-path', :request_block => request_block, :retry_limit => 2, :retry_interval => 0.1)
    request_block.rewound
  end

  tests("response_block rewound").returns(true) do
    run_count = 0
    Excon.stub({:method => :get}) { |params|
      run_count += 1
      if run_count <= 1 # First call fails.
        raise Excon::Errors::SocketError.new(Exception.new "Mock Error")
      else
        {:body => params[:body], :headers => params[:headers], :status => 200}
      end
    }
    response_block = Block.new
    @connection.request(:method => :get, :idempotent => true, :path => '/some-path', :response_block => response_block, :retry_limit => 2, :retry_interval => 0.1)
    response_block.rewound
  end

end
