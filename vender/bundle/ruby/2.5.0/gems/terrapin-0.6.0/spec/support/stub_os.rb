module StubOS
  def on_windows!
    stub_os('mswin')
    Terrapin::OS.stubs(:path_separator).returns(";")
  end

  def on_unix!
    stub_os('darwin11.0.0')
    Terrapin::OS.stubs(:path_separator).returns(":")
  end

  def on_mingw!
    stub_os('mingw')
    Terrapin::OS.stubs(:path_separator).returns(";")
  end

  def on_java!
    Terrapin::OS.stubs(:arch).returns("universal-java1.7")
  end

  def stub_os(host_string)
    # http://blog.emptyway.com/2009/11/03/proper-way-to-detect-windows-platform-in-ruby/
    RbConfig::CONFIG.stubs(:[]).with('host_os').returns(host_string)
  end
end
