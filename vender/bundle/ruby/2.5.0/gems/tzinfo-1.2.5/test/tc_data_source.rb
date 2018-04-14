require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')
require 'tmpdir'

include TZInfo

class TCDataSource < Minitest::Test
  class InitDataSource < DataSource
  end
  
  class DummyDataSource < DataSource
  end
  
  def setup
    @orig_data_source = DataSource.get
    DataSource.set(InitDataSource.new)
    @orig_search_path = ZoneinfoDataSource.search_path.clone
  end
  
  def teardown
    DataSource.set(@orig_data_source)
    ZoneinfoDataSource.search_path = @orig_search_path
  end
  
  def test_get
    data_source = DataSource.get
    assert_kind_of(InitDataSource, data_source)
  end
  
  def test_get_default_ruby_only    
    code = <<-EOF
      require 'tmpdir'
      
      begin
        Dir.mktmpdir('tzinfo_test_dir') do |dir|
          TZInfo::ZoneinfoDataSource.search_path = [dir]
          
          puts TZInfo::DataSource.get.class
        end
      rescue Exception => e
        puts "Unexpected exception: \#{e}"
      end
    EOF
    
    assert_sub_process_returns(['TZInfo::RubyDataSource'], code, [TZINFO_TEST_DATA_DIR])
  end
  
  def test_get_default_zoneinfo_only
    code = <<-EOF
      require 'tmpdir'
      
      begin
        Dir.mktmpdir('tzinfo_test_dir') do |dir|
          TZInfo::ZoneinfoDataSource.search_path = [dir, '#{TZINFO_TEST_ZONEINFO_DIR}']
          
          puts TZInfo::DataSource.get.class
          puts TZInfo::DataSource.get.zoneinfo_dir
        end
      rescue Exception => e
        puts "Unexpected exception: \#{e}"
      end
    EOF
    
    assert_sub_process_returns(
      ['TZInfo::ZoneinfoDataSource', TZINFO_TEST_ZONEINFO_DIR], 
      code)
  end
  
  def test_get_default_ruby_and_zoneinfo
    code = <<-EOF
      begin
        TZInfo::ZoneinfoDataSource.search_path = ['#{TZINFO_TEST_ZONEINFO_DIR}']
          
        puts TZInfo::DataSource.get.class
      rescue Exception => e
        puts "Unexpected exception: \#{e}"
      end
    EOF
    
    assert_sub_process_returns(['TZInfo::RubyDataSource'], code, [TZINFO_TEST_DATA_DIR])
  end
  
  def test_get_default_no_data
    code = <<-EOF
      require 'tmpdir'
      
      begin
        Dir.mktmpdir('tzinfo_test_dir') do |dir|
          TZInfo::ZoneinfoDataSource.search_path = [dir]
          
          begin
            data_source = TZInfo::DataSource.get
            puts "No exception raised, returned \#{data_source} instead"
          rescue Exception => e
            puts e.class
          end
        end
      rescue Exception => e
        puts "Unexpected exception: \#{e}"
      end
    EOF
    
    assert_sub_process_returns(['TZInfo::DataSourceNotFound'], code)
  end
  
  def test_set_instance
    DataSource.set(DummyDataSource.new)
    data_source = DataSource.get
    assert_kind_of(DummyDataSource, data_source)
  end
  
  def test_set_standard_ruby
    DataSource.set(:ruby)
    data_source = DataSource.get
    assert_kind_of(RubyDataSource, data_source)
  end
  
  def test_set_standard_zoneinfo_search
    Dir.mktmpdir('tzinfo_test_dir') do |dir|
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
      FileUtils.touch(File.join(dir, 'zone.tab'))
              
      ZoneinfoDataSource.search_path = [dir]
      
      DataSource.set(:zoneinfo)
      data_source = DataSource.get
      assert_kind_of(ZoneinfoDataSource, data_source)
      assert_equal(dir, data_source.zoneinfo_dir)      
    end
  end

  def test_set_standard_zoneinfo_search_zone1970
    Dir.mktmpdir('tzinfo_test_dir') do |dir|
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
      FileUtils.touch(File.join(dir, 'zone1970.tab'))

      ZoneinfoDataSource.search_path = [dir]

      DataSource.set(:zoneinfo)
      data_source = DataSource.get
      assert_kind_of(ZoneinfoDataSource, data_source)
      assert_equal(dir, data_source.zoneinfo_dir)
    end
  end
  
  def test_set_standard_zoneinfo_explicit
    Dir.mktmpdir('tzinfo_test_dir') do |dir|
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
      FileUtils.touch(File.join(dir, 'zone.tab'))      
      
      DataSource.set(:zoneinfo, dir)
      data_source = DataSource.get
      assert_kind_of(ZoneinfoDataSource, data_source)
      assert_equal(dir, data_source.zoneinfo_dir)      
    end
  end

  def test_set_standard_zoneinfo_explicit_zone1970
    Dir.mktmpdir('tzinfo_test_dir') do |dir|
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
      FileUtils.touch(File.join(dir, 'zone.tab'))

      DataSource.set(:zoneinfo, dir)
      data_source = DataSource.get
      assert_kind_of(ZoneinfoDataSource, data_source)
      assert_equal(dir, data_source.zoneinfo_dir)
    end
  end
  
  def test_set_standard_zoneinfo_explicit_alternate_iso3166
    Dir.mktmpdir('tzinfo_test_dir') do |dir|
      zoneinfo_dir = File.join(dir, 'zoneinfo')
      tab_dir = File.join(dir, 'tab')
      
      FileUtils.mkdir(zoneinfo_dir)
      FileUtils.mkdir(tab_dir)
    
      FileUtils.touch(File.join(zoneinfo_dir, 'zone.tab'))
      
      iso3166_file = File.join(tab_dir, 'iso3166.tab')
      FileUtils.touch(iso3166_file)
      
      DataSource.set(:zoneinfo, zoneinfo_dir, iso3166_file)
      data_source = DataSource.get
      assert_kind_of(ZoneinfoDataSource, data_source)
      assert_equal(zoneinfo_dir, data_source.zoneinfo_dir)
    end
  end
  
  def test_set_standard_zoneinfo_search_not_found
    Dir.mktmpdir('tzinfo_test_dir') do |dir|
      ZoneinfoDataSource.search_path = [dir]
      
      assert_raises(ZoneinfoDirectoryNotFound) do
        DataSource.set(:zoneinfo)
      end
      
      assert_kind_of(InitDataSource, DataSource.get)
    end
  end
  
  def test_set_standard_zoneinfo_explicit_invalid
    Dir.mktmpdir('tzinfo_test_dir') do |dir|
      assert_raises(InvalidZoneinfoDirectory) do
        DataSource.set(:zoneinfo, dir)
      end
      
      assert_kind_of(InitDataSource, DataSource.get)      
    end
  end
  
  def test_set_standard_zoneinfo_wrong_arg_count
    assert_raises(ArgumentError) do
      DataSource.set(:zoneinfo, 1, 2, 3)
    end
    
    assert_kind_of(InitDataSource, DataSource.get)
  end
end
