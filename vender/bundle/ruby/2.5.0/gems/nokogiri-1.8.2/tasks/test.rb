namespace :test do
  desc "run test suite with aggressive GC"
  task :gc => :build do
    ENV['NOKOGIRI_GC'] = "true"
    Rake::Task["test"].invoke
  end

  task :installed do
    ENV['RUBY_FLAGS'] = "-w -Itest:."
    sh 'rake test'
  end

  desc "find call-seq in the rdoc"
  task :rdoc_call_seq => 'docs' do
    Dir['doc/**/*.html'].each { |docfile|
      next if docfile =~ /\.src/
      puts "FAIL: #{docfile}" if File.read(docfile) =~ /call-seq/
    }
  end

  desc "find all undocumented things"
  task :rdoc => 'docs' do
    base = File.expand_path(File.join(File.dirname(__FILE__), '..', 'doc'))
    require 'test/unit'
    test = Class.new(Test::Unit::TestCase)
    Dir["#{base}/**/*.html"].each { |docfile|
      test.class_eval(<<-eotest)
        def test_#{docfile.sub("#{base}/", '').gsub(/[\/\.-]/, '_')}
          assert_no_match(
            /Not documented/,
            File.read('#{docfile}'),
            '#{docfile} has undocumented things'
          )
        end
      eotest
    }
  end

  desc "Test against multiple versions of libxml2 (MULTIXML2_DIR=directory)"
  task :multixml2 do
    MULTI_XML = File.join(ENV['HOME'], '.multixml2')
    unless File.exists?(MULTI_XML)
      %w{ versions install build }.each { |x|
        FileUtils.mkdir_p(File.join(MULTI_XML, x))
      }
      Dir.chdir File.join(MULTI_XML, 'versions') do
        require 'net/ftp'
        puts "Contacting xmlsoft.org ..."
        ftp = Net::FTP.new('xmlsoft.org')
        ftp.login('anonymous', 'anonymous')
        ftp.chdir('libxml2')
        ftp.list('libxml2-2.*.tar.gz').each do |x|
          file = x[/[^\s]*$/]
          puts "Downloading #{file}"
          ftp.getbinaryfile(file)
        end
      end
    end

    # Build any libxml2 versions in $HOME/.multixml2/versions that
    # haven't been built yet
    Dir[File.join(MULTI_XML, 'versions','*.tar.gz')].each do |f|
      filename = File.basename(f, '.tar.gz')

      install_dir = File.join(MULTI_XML, 'install', filename)
      next if File.exists?(install_dir)

      Dir.chdir File.join(MULTI_XML, 'versions') do
        system "tar zxvf #{f} -C #{File.join(MULTI_XML, 'build')}"
      end

      Dir.chdir File.join(MULTI_XML, 'build', filename) do
        system "./configure --without-http --prefix=#{install_dir}"
        system "make && make install"
      end
    end

    test_results = {}
    libxslt = Dir[File.join(MULTI_XML, 'install', 'libxslt*')].first

    directories = ENV['MULTIXML2_DIR'] ? [ENV['MULTIXML2_DIR']] : Dir[File.join(MULTI_XML, 'install', '*')]
    directories.sort.reverse_each do |xml2_version|
      next unless xml2_version =~ /libxml2/
      extopts = "--with-xml2-include=#{xml2_version}/include/libxml2 --with-xml2-lib=#{xml2_version}/lib --with-xslt-dir=#{libxslt} --with-iconv-dir=/usr"
      cmd = "#{$0} clean test EXTOPTS='#{extopts}' LD_LIBRARY_PATH='#{xml2_version}/lib'"

      version = File.basename(xml2_version)
      result = system(cmd)
      test_results[version] = {
        :result => result,
        :cmd    => cmd
      }
    end
    test_results.sort_by { |k,v| k }.each do |k,v|
      passed = v[:result]
      puts "#{k}: #{passed ? 'PASS' : 'FAIL'}"
      puts "repro: #{v[:cmd]}" unless passed
    end
  end
end
