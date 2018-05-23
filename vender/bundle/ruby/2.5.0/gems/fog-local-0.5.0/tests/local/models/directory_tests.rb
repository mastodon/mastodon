Shindo.tests('Storage[:local] | directory', ["local"]) do

  pending if Fog.mocking?

  before do
    @options = { :local_root => Dir.mktmpdir('fog-tests') }
  end

  after do
    FileUtils.remove_entry_secure @options[:local_root]
  end

  tests('save') do
    returns('directory') do
      connection = Fog::Storage::Local.new(@options)
      connection.directories.create(:key => 'directory')
      connection.directories.create(:key => 'directory').key
    end
  end
end
