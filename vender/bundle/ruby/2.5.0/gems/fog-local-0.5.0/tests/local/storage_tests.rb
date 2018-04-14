Shindo.tests('Local | storage') do

  pending if Fog.mocking?

  before do
    @options = { :local_root => Dir.mktmpdir('fog-tests') }
  end

  after do
    FileUtils.remove_entry_secure @options[:local_root]
  end

  tests('#endpoint') do
    tests('when no endpoint is provided').
      returns(nil) do
        Fog::Storage::Local.new(@options).endpoint
      end

    tests('when no host is provided').
      returns(nil) do
        @options[:scheme] = 'http'
        @options[:path] = '/files'
        @options[:port] = 80

        Fog::Storage::Local.new(@options).endpoint
      end

    tests('when endpoint is provided').
      returns('http://example.com/files') do
        @options[:endpoint] = 'http://example.com/files'

        Fog::Storage::Local.new(@options).endpoint
      end

    tests('when at least host option is provided').
      returns('http://example.com/files') do
        @options[:scheme] = 'http'
        @options[:host] = 'example.com'
        @options[:path] = '/files'

        Fog::Storage::Local.new(@options).endpoint
      end
  end
end
