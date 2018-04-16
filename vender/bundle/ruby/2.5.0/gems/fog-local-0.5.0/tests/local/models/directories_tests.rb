Shindo.tests('Storage[:local] | directories', ["local"]) do

  pending if Fog.mocking?

  @options = { :local_root => Dir.mktmpdir('fog-tests') }
  @collection = Fog::Storage::Local.new(@options).directories

  collection_tests(@collection, {:key => "fogdirtests"}, true)

  tests("#all") do
    tests("succeeds when :local_root does not exist").succeeds do
      FileUtils.remove_entry_secure(@options[:local_root])
      @collection.all
    end
  end

  FileUtils.remove_entry_secure(@options[:local_root]) if File.directory?(@options[:local_root])
end
