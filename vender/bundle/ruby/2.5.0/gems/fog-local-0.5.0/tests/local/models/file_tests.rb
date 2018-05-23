Shindo.tests('Storage[:local] | file', ["local"]) do

  pending if Fog.mocking?

  before do
    @options = { :local_root => Dir.mktmpdir('fog-tests') }
  end

  after do
    FileUtils.remove_entry_secure @options[:local_root]
  end

  tests('#public_url') do
    tests('when connection has an endpoint').
      returns('http://example.com/files/directory/file.txt') do
        @options[:endpoint] = 'http://example.com/files'

        connection = Fog::Storage::Local.new(@options)
        directory = connection.directories.new(:key => 'directory')
        file = directory.files.new(:key => 'file.txt')

        file.public_url
      end

    tests('when connection has no endpoint').
      returns(nil) do
        @options[:endpoint] = nil

        connection = Fog::Storage::Local.new(@options)
        directory = connection.directories.new(:key => 'directory')
        file = directory.files.new(:key => 'file.txt')

        file.public_url
      end

    tests('when file path has escapable characters').
      returns('http://example.com/files/my%20directory/my%20file.txt') do
        @options[:endpoint] = 'http://example.com/files'

        connection = Fog::Storage::Local.new(@options)
        directory = connection.directories.new(:key => 'my directory')
        file = directory.files.new(:key => 'my file.txt')

        file.public_url
      end
  end

  tests('#save') do
    tests('creates non-existent subdirs') do
      returns(true) do
        connection = Fog::Storage::Local.new(@options)
        directory = connection.directories.new(:key => 'path1')
        file = directory.files.new(:key => 'path2/file.rb', :body => "my contents")
        file.save
        File.exists?(@options[:local_root] + "/path1/path2/file.rb")
      end
    end

    tests('with tempfile').returns('tempfile') do
      connection = Fog::Storage::Local.new(@options)
      directory = connection.directories.create(:key => 'directory')

      tempfile = Tempfile.new(['file', '.txt'])
      tempfile.write('tempfile')
      tempfile.rewind

      tempfile.instance_eval do
        def read
          raise 'must not be read'
        end
      end
      file = directory.files.new(:key => 'tempfile.txt', :body => tempfile)
      file.save
      tempfile.close
      tempfile.unlink
      directory.files.get('tempfile.txt').body
    end
  end
end
