# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')
require 'fileutils'
require 'pathname'
require 'tmpdir'

include TZInfo

class TCZoneinfoDataSource < Minitest::Test
  ZONEINFO_DIR = File.join(File.expand_path(File.dirname(__FILE__)), 'zoneinfo').untaint
  
  def setup
    @orig_search_path = ZoneinfoDataSource.search_path.clone
    @orig_alternate_iso3166_tab_search_path = ZoneinfoDataSource.alternate_iso3166_tab_search_path.clone
    @orig_pwd = FileUtils.pwd
    
    # A zoneinfo directory containing files needed by the tests.
    # The symlinks in this directory are set up in test_utils.rb.
    @data_source = ZoneinfoDataSource.new(ZONEINFO_DIR)
  end
  
  def teardown
    ZoneinfoDataSource.search_path = @orig_search_path
    ZoneinfoDataSource.alternate_iso3166_tab_search_path = @orig_alternate_iso3166_tab_search_path
    FileUtils.chdir(@orig_pwd)
  end
  
  def test_default_search_path
    assert_equal(['/usr/share/zoneinfo', '/usr/share/lib/zoneinfo', '/etc/zoneinfo'], ZoneinfoDataSource.search_path)
    assert_equal(false, ZoneinfoDataSource.search_path.frozen?)
  end
  
  def test_set_search_path_default
    ZoneinfoDataSource.search_path = ['/tmp/zoneinfo1', '/tmp/zoneinfo2']
    assert_equal(['/tmp/zoneinfo1', '/tmp/zoneinfo2'], ZoneinfoDataSource.search_path)
    
    ZoneinfoDataSource.search_path = nil
    assert_equal(['/usr/share/zoneinfo', '/usr/share/lib/zoneinfo', '/etc/zoneinfo'], ZoneinfoDataSource.search_path)
    assert_equal(false, ZoneinfoDataSource.search_path.frozen?)
  end
  
  def test_set_search_path_array
    path = ['/tmp/zoneinfo1', '/tmp/zoneinfo2']
    ZoneinfoDataSource.search_path = path
    assert_equal(['/tmp/zoneinfo1', '/tmp/zoneinfo2'], ZoneinfoDataSource.search_path)
    refute_same(path, ZoneinfoDataSource.search_path)
  end
  
  def test_set_search_path_array_to_s  
    ZoneinfoDataSource.search_path = [Pathname.new('/tmp/zoneinfo3')]
    assert_equal(['/tmp/zoneinfo3'], ZoneinfoDataSource.search_path)
  end
  
  def test_set_search_path_string
    ZoneinfoDataSource.search_path = ['/tmp/zoneinfo4', '/tmp/zoneinfo5'].join(File::PATH_SEPARATOR)
    assert_equal(['/tmp/zoneinfo4', '/tmp/zoneinfo5'], ZoneinfoDataSource.search_path)
  end
  
  def test_default_alternate_iso3166_tab_search_path
    assert_equal(['/usr/share/misc/iso3166.tab', '/usr/share/misc/iso3166'], ZoneinfoDataSource.alternate_iso3166_tab_search_path)
    assert_equal(false, ZoneinfoDataSource.alternate_iso3166_tab_search_path.frozen?)
  end
  
  def test_set_alternate_iso3166_tab_search_path_default
    ZoneinfoDataSource.alternate_iso3166_tab_search_path = ['/tmp/iso3166.tab', '/tmp/iso3166']
    assert_equal(['/tmp/iso3166.tab', '/tmp/iso3166'], ZoneinfoDataSource.alternate_iso3166_tab_search_path)
    
    ZoneinfoDataSource.alternate_iso3166_tab_search_path = nil
    assert_equal(['/usr/share/misc/iso3166.tab', '/usr/share/misc/iso3166'], ZoneinfoDataSource.alternate_iso3166_tab_search_path)
    assert_equal(false, ZoneinfoDataSource.alternate_iso3166_tab_search_path.frozen?)
  end
  
  def test_set_alternate_iso3166_tab_search_path_array
    path = ['/tmp/iso3166.tab', '/tmp/iso3166']
    ZoneinfoDataSource.alternate_iso3166_tab_search_path = path
    assert_equal(['/tmp/iso3166.tab', '/tmp/iso3166'], ZoneinfoDataSource.alternate_iso3166_tab_search_path)
    refute_same(path, ZoneinfoDataSource.alternate_iso3166_tab_search_path)
  end
  
  def test_set_alternate_iso3166_tab_search_path_array_to_s  
    ZoneinfoDataSource.alternate_iso3166_tab_search_path = [Pathname.new('/tmp/iso3166.tab')]
    assert_equal(['/tmp/iso3166.tab'], ZoneinfoDataSource.alternate_iso3166_tab_search_path)
  end
  
  def test_set_alternate_iso3166_tab_search_path_string
    ZoneinfoDataSource.alternate_iso3166_tab_search_path = ['/tmp/iso3166.tab', '/tmp/iso3166'].join(File::PATH_SEPARATOR)
    assert_equal(['/tmp/iso3166.tab', '/tmp/iso3166'], ZoneinfoDataSource.alternate_iso3166_tab_search_path)
  end
  
  def test_new_search
    Dir.mktmpdir('tzinfo_test_dir1') do |dir1|
      Dir.mktmpdir('tzinfo_test_dir2') do |dir2|
        Dir.mktmpdir('tzinfo_test_dir3') do |dir3|
          Dir.mktmpdir('tzinfo_test_dir4') do |dir4|
            file = File.join(dir1, 'file')
            FileUtils.touch(File.join(dir2, 'zone.tab'))
            FileUtils.touch(File.join(dir3, 'iso3166.tab'))
            FileUtils.touch(File.join(dir4, 'zone.tab'))
            FileUtils.touch(File.join(dir4, 'iso3166.tab'))
            
            ZoneinfoDataSource.search_path = [file, dir2, dir3, dir4]
            ZoneinfoDataSource.alternate_iso3166_tab_search_path = []
            
            data_source = ZoneinfoDataSource.new
            assert_equal(dir4, data_source.zoneinfo_dir)
          end
        end
      end
    end
  end

  def test_new_search_zone1970
    Dir.mktmpdir('tzinfo_test_dir1') do |dir1|
      Dir.mktmpdir('tzinfo_test_dir2') do |dir2|
        Dir.mktmpdir('tzinfo_test_dir3') do |dir3|
          Dir.mktmpdir('tzinfo_test_dir4') do |dir4|
            file = File.join(dir1, 'file')
            FileUtils.touch(File.join(dir2, 'zone1970.tab'))
            FileUtils.touch(File.join(dir3, 'iso3166.tab'))
            FileUtils.touch(File.join(dir4, 'zone1970.tab'))
            FileUtils.touch(File.join(dir4, 'iso3166.tab'))

            ZoneinfoDataSource.search_path = [file, dir2, dir3, dir4]
            ZoneinfoDataSource.alternate_iso3166_tab_search_path = []

            data_source = ZoneinfoDataSource.new
            assert_equal(dir4, data_source.zoneinfo_dir)
          end
        end
      end
    end
  end
  
  def test_new_search_solaris_tab_files
    # Solaris names the tab files 'tab/country.tab' (iso3166.tab) and 
    # 'tab/zone_sun.tab' (zone.tab).
    
    Dir.mktmpdir('tzinfo_test_dir') do |dir|
      tab = File.join(dir, 'tab')
      FileUtils.mkdir(tab)
      FileUtils.touch(File.join(tab, 'country.tab'))
      FileUtils.touch(File.join(tab, 'zone_sun.tab'))

      ZoneinfoDataSource.search_path = [dir]
      ZoneinfoDataSource.alternate_iso3166_tab_search_path = []

      data_source = ZoneinfoDataSource.new
      assert_equal(dir, data_source.zoneinfo_dir)
    end
  end
  
  def test_new_search_alternate_iso3166_path
    Dir.mktmpdir('tzinfo_test_dir_zoneinfo') do |zoneinfo_dir|
      Dir.mktmpdir('tzinfo_test_dir_tab') do |tab_dir|
        FileUtils.touch(File.join(zoneinfo_dir, 'zone.tab'))
        
        tab_file = File.join(tab_dir, 'iso3166')
        
        ZoneinfoDataSource.search_path = [zoneinfo_dir]
        ZoneinfoDataSource.alternate_iso3166_tab_search_path = [tab_file]
        
        assert_raises(ZoneinfoDirectoryNotFound) do
          ZoneinfoDataSource.new
        end
        
        FileUtils.touch(tab_file)
      
        data_source = ZoneinfoDataSource.new
        assert_equal(zoneinfo_dir, data_source.zoneinfo_dir)
      end
    end
  end
  
  def test_new_search_not_found
    Dir.mktmpdir('tzinfo_test_dir1') do |dir1|
      Dir.mktmpdir('tzinfo_test_dir2') do |dir2|
        Dir.mktmpdir('tzinfo_test_dir3') do |dir3|
          Dir.mktmpdir('tzinfo_test_dir4') do |dir4|
            Dir.mktmpdir('tzinfo_test_dir5') do |dir5|
              file = File.join(dir1, 'file')
              FileUtils.touch(file)
              FileUtils.touch(File.join(dir2, 'zone.tab'))
              FileUtils.touch(File.join(dir3, 'zone1970.tab'))
              FileUtils.touch(File.join(dir4, 'iso3166.tab'))

              ZoneinfoDataSource.search_path = [file, dir2, dir3, dir4, dir5]
              ZoneinfoDataSource.alternate_iso3166_tab_search_path = []

              assert_raises(ZoneinfoDirectoryNotFound) do
                ZoneinfoDataSource.new
              end
            end
          end
        end
      end
    end
  end
  
  def test_new_search_relative
    Dir.mktmpdir('tzinfo_test') do |dir|
      FileUtils.touch(File.join(dir, 'zone.tab'))
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
      
      FileUtils.chdir(dir)
      
      ZoneinfoDataSource.search_path = ['.']
      ZoneinfoDataSource.alternate_iso3166_tab_search_path = []
      data_source = ZoneinfoDataSource.new
      assert_equal(Pathname.new(dir).realpath.to_s, data_source.zoneinfo_dir)
      
      # Change out of the directory to allow it to be deleted on Windows.
      FileUtils.chdir(@orig_pwd)
    end
  end
  
  def test_new_dir
    Dir.mktmpdir('tzinfo_test') do |dir|
      FileUtils.touch(File.join(dir, 'zone.tab'))
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
      
      data_source = ZoneinfoDataSource.new(dir)
      assert_equal(dir, data_source.zoneinfo_dir)
    end
  end

  def test_new_dir_zone1970
    Dir.mktmpdir('tzinfo_test') do |dir|
      FileUtils.touch(File.join(dir, 'zone1970.tab'))
      FileUtils.touch(File.join(dir, 'iso3166.tab'))

      data_source = ZoneinfoDataSource.new(dir)
      assert_equal(dir, data_source.zoneinfo_dir)
    end
  end
  
  def test_new_dir_solaris_tab_files
    # Solaris names the tab files 'tab/country.tab' (iso3166.tab) and 
    # 'tab/zone_sun.tab' (zone.tab).
    
    Dir.mktmpdir('tzinfo_test') do |dir|
      tab = File.join(dir, 'tab')
      FileUtils.mkdir(tab)
      FileUtils.touch(File.join(tab, 'country.tab'))
      FileUtils.touch(File.join(tab, 'zone_sun.tab'))
            
      data_source = ZoneinfoDataSource.new(dir)
      assert_equal(dir, data_source.zoneinfo_dir)
    end
  end
  
  def test_new_dir_alternate_iso3166_path
    Dir.mktmpdir('tzinfo_test_dir_zoneinfo') do |zoneinfo_dir|
      Dir.mktmpdir('tzinfo_test_dir_tab') do |tab_dir|
        FileUtils.touch(File.join(zoneinfo_dir, 'zone.tab'))
        
        tab_file = File.join(tab_dir, 'iso3166')
        FileUtils.touch(tab_file)
        
        ZoneinfoDataSource.alternate_iso3166_tab_search_path = [tab_file]
        
        assert_raises(InvalidZoneinfoDirectory) do
          # The alternate_iso3166_tab_search_path should not be used. This should raise 
          # an exception.
          ZoneinfoDataSource.new(zoneinfo_dir)
        end
        
        data_source = ZoneinfoDataSource.new(zoneinfo_dir, tab_file)
        assert_equal(zoneinfo_dir, data_source.zoneinfo_dir)
      end
    end
  end
  
  def test_new_dir_invalid
    Dir.mktmpdir('tzinfo_test') do |dir|
      assert_raises(InvalidZoneinfoDirectory) do
        ZoneinfoDataSource.new(dir)
      end
    end
  end
  
  def test_new_dir_invalid_alternate_iso3166_path
    Dir.mktmpdir('tzinfo_test_dir_zoneinfo') do |zoneinfo_dir|
      Dir.mktmpdir('tzinfo_test_dir_tab') do |tab_dir|
        FileUtils.touch(File.join(zoneinfo_dir, 'zone.tab'))
        
        assert_raises(InvalidZoneinfoDirectory) do
          ZoneinfoDataSource.new(zoneinfo_dir, File.join(tab_dir, 'iso3166'))
        end
      end
    end
  end
  
  def test_new_dir_invalid_alternate_iso3166_path_overrides_valid
    Dir.mktmpdir('tzinfo_test_dir_zoneinfo') do |zoneinfo_dir|
      Dir.mktmpdir('tzinfo_test_dir_tab') do |tab_dir|
        FileUtils.touch(File.join(zoneinfo_dir, 'iso3166.tab'))
        FileUtils.touch(File.join(zoneinfo_dir, 'zone.tab'))
        
        assert_raises(InvalidZoneinfoDirectory) do
          ZoneinfoDataSource.new(zoneinfo_dir, File.join(tab_dir, 'iso3166'))
        end
      end
    end
  end
  
  def test_new_file
    Dir.mktmpdir('tzinfo_test') do |dir|
      file = File.join(dir, 'file')
      FileUtils.touch(file)
      
      assert_raises(InvalidZoneinfoDirectory) do
        ZoneinfoDataSource.new(file)
      end
    end
  end

  def test_new_dir_relative
    Dir.mktmpdir('tzinfo_test') do |dir|
      FileUtils.touch(File.join(dir, 'zone.tab'))
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
      
      FileUtils.chdir(dir)
      
      data_source = ZoneinfoDataSource.new('.')
      assert_equal(Pathname.new(dir).realpath.to_s, data_source.zoneinfo_dir)
      
      # Change out of the directory to allow it to be deleted on Windows.
      FileUtils.chdir(@orig_pwd)
    end
  end
  
  def test_zoneinfo_dir
    Dir.mktmpdir('tzinfo_test') do |dir|
      FileUtils.touch(File.join(dir, 'zone.tab'))
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
      
      data_source = ZoneinfoDataSource.new(dir)
      assert_equal(dir, data_source.zoneinfo_dir)
      assert_equal(true, data_source.zoneinfo_dir.frozen?)
    end
  end
  
  def test_load_timezone_info_data
    info = @data_source.load_timezone_info('Europe/London')
    assert_kind_of(ZoneinfoTimezoneInfo, info)
    assert_equal('Europe/London', info.identifier)
  end
  
  def test_load_timezone_info_linked
    info = @data_source.load_timezone_info('UTC')
    
    # On platforms that don't support symlinks, 'UTC' will be created as a copy.
    # Either way, a ZoneinfoTimezoneInfo should be returned.
    
    assert_kind_of(ZoneinfoTimezoneInfo, info)
    assert_equal('UTC', info.identifier)
  end
  
  def test_load_timezone_info_does_not_exist
    assert_raises(InvalidTimezoneIdentifier) do
      @data_source.load_timezone_info('Nowhere/Special')
    end
  end
  
  def test_load_timezone_info_invalid
    assert_raises(InvalidTimezoneIdentifier) do
      @data_source.load_timezone_info('../Definitions/Europe/London')
    end
  end
  
  %w(leapseconds localtime).each do |file_name|
    define_method("test_load_timezone_info_ignored_#{file_name}_file") do
      assert_raises(InvalidTimezoneIdentifier) do
        @data_source.load_timezone_info(file_name)
      end
    end
  end
  
  def test_load_timezone_info_ignored_plus_version_file
    # Mac OS X includes a file named +VERSION containing the tzdata version.
    
    Dir.mktmpdir('tzinfo_test') do |dir|
      FileUtils.touch(File.join(dir, 'zone.tab'))
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
      
      File.open(File.join(dir, '+VERSION'), 'w') do |f|
        f.binmode
        f.write("2013a\n")
      end
      
      data_source = ZoneinfoDataSource.new(dir)
      
      assert_raises(InvalidTimezoneIdentifier) do
        data_source.load_timezone_info('+VERSION')
      end
    end
  end
  
  def test_load_timezone_info_ignored_timeconfig_symlink
    # Slackware includes a symlink named timeconfig that points at /usr/sbin/timeconfig.

    Dir.mktmpdir('tzinfo_test_target') do |target_dir|
      target_path = File.join(target_dir, 'timeconfig')

      File.open(target_path, 'w') do |f|
        f.write("#!/bin/sh\n")
        f.write("#\n")
        f.write('# timeconfig         Slackware Linux timezone configuration utility.\n')
      end

      Dir.mktmpdir('tzinfo_test') do |dir|
        FileUtils.touch(File.join(dir, 'zone.tab'))
        FileUtils.touch(File.join(dir, 'iso3166.tab'))
        FileUtils.cp(File.join(@data_source.zoneinfo_dir, 'EST'), File.join(dir, 'EST'))

        symlink_path = File.join(dir, 'timeconfig')
        begin
          FileUtils.ln_s(target_path, symlink_path)
        rescue NotImplementedError, Errno::EACCES
          # Symlinks not supported on this platform, or permission denied
          # (administrative rights are required on Windows). Copy instead.
          FileUtils.cp(target_path, symlink_path)
        end

        data_source = ZoneinfoDataSource.new(dir)

        assert_raises(InvalidTimezoneIdentifier) do
          data_source.load_timezone_info('timeconfig')
        end
      end
    end
  end

  def test_load_timezone_info_nil
    assert_raises(InvalidTimezoneIdentifier) do
      @data_source.load_timezone_info(nil)
    end
  end
  
  def test_load_timezone_info_case
    assert_raises(InvalidTimezoneIdentifier) do
      @data_source.load_timezone_info('europe/london')
    end
  end

  def test_load_timezone_info_permission_denied
    Dir.mktmpdir('tzinfo_test') do |dir|
      FileUtils.touch(File.join(dir, 'zone.tab'))
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
      
      file = File.join(dir, 'UTC')
      FileUtils.touch(file)
      FileUtils.chmod(0200, file)      
      
      data_source = ZoneinfoDataSource.new(dir)
      
      assert_raises(InvalidTimezoneIdentifier) do
        data_source.load_timezone_info('UTC')
      end
    end
  end
  
  def test_load_timezone_info_directory
    Dir.mktmpdir('tzinfo_test') do |dir|
      FileUtils.touch(File.join(dir, 'zone.tab'))
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
      
      subdir = File.join(dir, 'Subdir')
      FileUtils.mkdir(subdir)     
      
      data_source = ZoneinfoDataSource.new(dir)
      
      assert_raises(InvalidTimezoneIdentifier) do
        data_source.load_timezone_info('Subdir')
      end
    end
  end
  
  def test_load_timezone_info_linked_absolute_outside
    Dir.mktmpdir('tzinfo_test') do |dir|
      Dir.mktmpdir('tzinfo_test') do |outside|
        outside_file = File.join(outside, 'EST')
        FileUtils.cp(File.join(@data_source.zoneinfo_dir, 'EST'), outside_file)
        
        FileUtils.touch(File.join(dir, 'zone.tab'))
        FileUtils.touch(File.join(dir, 'iso3166.tab'))
        
        file = File.join(dir, 'EST')
        
        begin
          FileUtils.ln_s(outside_file, file)
        rescue NotImplementedError, Errno::EACCES
          # Symlinks not supported on this platform, or permission denied
          # (administrative rights are required on Windows). Skip test.
          return
        end
        
        data_source = ZoneinfoDataSource.new(dir)
        
        info = data_source.load_timezone_info('EST')
        assert_kind_of(ZoneinfoTimezoneInfo, info)
        assert_equal('EST', info.identifier)
      end
    end
  end
  
  def test_load_timezone_info_linked_absolute_inside
    Dir.mktmpdir('tzinfo_test') do |dir|
      FileUtils.touch(File.join(dir, 'zone.tab'))
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
      
      FileUtils.cp(File.join(@data_source.zoneinfo_dir, 'EST'), File.join(dir, 'EST'))
      
      link = File.join(dir, 'Link')
      
      begin  
        FileUtils.ln_s(File.join(File.expand_path(dir), 'EST'), link)      
      rescue NotImplementedError, Errno::EACCES
        # Symlinks not supported on this platform, or permission denied
        # (administrative rights are required on Windows). Skip test.
        return
      end
      
      data_source = ZoneinfoDataSource.new(dir)
      
      info = data_source.load_timezone_info('Link')
      assert_kind_of(ZoneinfoTimezoneInfo, info)
      assert_equal('Link', info.identifier)
    end
  end

  def test_load_timezone_info_linked_relative_outside
    Dir.mktmpdir('tzinfo_test') do |root|
      FileUtils.cp(File.join(@data_source.zoneinfo_dir, 'EST'), File.join(root, 'outside'))
      
      dir = File.join(root, 'zoneinfo')
      FileUtils.mkdir(dir)
      
      FileUtils.touch(File.join(dir, 'zone.tab'))
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
      
      link = File.join(dir, 'Link')      
      
      begin
        FileUtils.ln_s('../outside', link)
      rescue NotImplementedError, Errno::EACCES
        # Symlinks not supported on this platform, or permission denied
        # (administrative rights are required on Windows). Skip test.
        return
      end
      
      subdir = File.join(dir, 'Subdir')
      subdir_link = File.join(subdir, 'Link')
      FileUtils.mkdir(subdir)
      FileUtils.ln_s('../../outside', subdir_link)
      
      data_source = ZoneinfoDataSource.new(dir)
      
      info = data_source.load_timezone_info('Link')
      assert_kind_of(ZoneinfoTimezoneInfo, info)
      assert_equal('Link', info.identifier)
      
      info = data_source.load_timezone_info('Subdir/Link')
      assert_kind_of(ZoneinfoTimezoneInfo, info)
      assert_equal('Subdir/Link', info.identifier)
    end
  end
  
  def test_load_timezone_info_linked_relative_parent_inside
    Dir.mktmpdir('tzinfo_test') do |dir|
      FileUtils.touch(File.join(dir, 'zone.tab'))
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
      
      FileUtils.cp(File.join(@data_source.zoneinfo_dir, 'EST'), File.join(dir, 'EST'))
       
      subdir = File.join(dir, 'Subdir')
      FileUtils.mkdir(subdir)
      FileUtils.cp(File.join(@data_source.zoneinfo_dir, 'EST'), File.join(subdir, 'EST'))
      
      subdir_link = File.join(subdir, 'Link')
      begin
        FileUtils.ln_s('../Subdir/EST', subdir_link)
      rescue NotImplementedError, Errno::EACCES
        # Symlinks not supported on this platform, or permission denied
        # (administrative rights are required on Windows). Skip test.
        return
      end
      
      subdir_link2 = File.join(subdir, 'Link2')
      FileUtils.ln_s('../EST', subdir_link2)
      
      subdir2 = File.join(dir, 'Subdir2')
      FileUtils.mkdir(subdir2)
      subdir2_link = File.join(subdir2, 'Link')
      FileUtils.ln_s('../Subdir/EST', subdir2_link)
      
      data_source = ZoneinfoDataSource.new(dir)
      
      info = data_source.load_timezone_info('Subdir/Link')
      assert_kind_of(ZoneinfoTimezoneInfo, info)
      assert_equal('Subdir/Link', info.identifier)
      
      info = data_source.load_timezone_info('Subdir/Link2')
      assert_kind_of(ZoneinfoTimezoneInfo, info)
      assert_equal('Subdir/Link2', info.identifier)
      
      info = data_source.load_timezone_info('Subdir2/Link')
      assert_kind_of(ZoneinfoTimezoneInfo, info)
      assert_equal('Subdir2/Link', info.identifier)
    end
  end
  
  def test_load_timezone_info_invalid_file
    Dir.mktmpdir('tzinfo_test') do |dir|
      FileUtils.touch(File.join(dir, 'zone.tab'))
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
  
      File.open(File.join(dir, 'Zone'), 'wb') do |file|
        file.write('NotAValidTZifFile')        
      end
      
      data_source = ZoneinfoDataSource.new(dir)
      
      assert_raises(InvalidTimezoneIdentifier) do
        data_source.load_timezone_info('Zone')
      end      
    end
  end
    
  def test_load_timezone_info_invalid_file_2
    Dir.mktmpdir('tzinfo_test') do |dir|
      FileUtils.touch(File.join(dir, 'zone.tab'))
      FileUtils.touch(File.join(dir, 'iso3166.tab'))

      zone = File.join(dir, 'Zone')      
      
      File.open(File.join(@data_source.zoneinfo_dir, 'EST')) do |src|
        # Change header to TZif1 (which is not a valid header).
        File.open(zone, 'wb') do |dest|
          dest.write('TZif1')
          src.pos = 5
          FileUtils.copy_stream(src, dest)
        end
      end
      
      data_source = ZoneinfoDataSource.new(dir)
      
      assert_raises(InvalidTimezoneIdentifier) do
        data_source.load_timezone_info('Zone')
      end      
    end
  end

  def test_load_timezone_info_tainted
    safe_test do
      identifier = 'Europe/Amsterdam'.dup.taint
      assert(identifier.tainted?)
      info = @data_source.load_timezone_info(identifier)
      assert_equal('Europe/Amsterdam', info.identifier)
      assert(identifier.tainted?)
    end
  end
  
  def test_load_timezone_info_tainted_and_frozen
    safe_test do
      info = @data_source.load_timezone_info('Europe/Amsterdam'.dup.taint.freeze)
      assert_equal('Europe/Amsterdam', info.identifier)
    end
  end
  
  def test_load_timezone_info_tainted_zoneinfo_dir_safe_mode
    safe_test(:unavailable => :skip) do
      assert_raises(SecurityError) do
        ZoneinfoDataSource.new(@data_source.zoneinfo_dir.dup.taint)
      end
    end
  end
  
  def test_load_timezone_info_tainted_zoneinfo_dir
    data_source = ZoneinfoDataSource.new(@data_source.zoneinfo_dir.dup.taint)
    info = data_source.load_timezone_info('Europe/London')
    assert_kind_of(ZoneinfoTimezoneInfo, info)
    assert_equal('Europe/London', info.identifier)
  end
  
  def get_timezone_filenames(directory)
    entries = Dir.glob(File.join(directory, '**', '*'))
    
    entries = entries.select do |file|
      file.untaint
      File.file?(file)
    end
       
    entries = entries.collect {|file| file[directory.length + File::SEPARATOR.length, file.length - directory.length - File::SEPARATOR.length]}

    # Exclude right (with leapseconds) and posix (copy) directories; .tab files; leapseconds, localtime and posixrules files.
    entries = entries.select do |file| 
      file !~ /\A(posix|right)\// &&
        file !~ /\.tab\z/ &&
        !%w(leapseconds localtime posixrules).include?(file)
    end
    
    entries.sort
  end

  def test_timezone_identifiers
    expected = get_timezone_filenames(@data_source.zoneinfo_dir)
    all = @data_source.timezone_identifiers
    assert_kind_of(Array, all)
    assert_array_same_items(expected, all)
    assert_equal(true, all.frozen?)
  end
  
  def test_data_timezone_identifiers
    expected = get_timezone_filenames(@data_source.zoneinfo_dir)
    all_data = @data_source.data_timezone_identifiers
    assert_kind_of(Array, all_data)
    assert_array_same_items(expected, all_data)
    assert_equal(true, all_data.frozen?)
  end
  
  def test_linked_timezone_identifiers
    all_linked = @data_source.linked_timezone_identifiers
    assert_kind_of(Array, all_linked)
    assert_equal(true, all_linked.empty?)
    assert_equal(true, all_linked.frozen?)
  end
  
  def test_timezone_identifiers_safe_mode
    safe_test do
      expected = get_timezone_filenames(@data_source.zoneinfo_dir)
      all = @data_source.timezone_identifiers
      assert_kind_of(Array, all)
      assert_array_same_items(expected, all)
      assert_equal(true, all.frozen?)
    end
  end
  
  def test_timezone_identifiers_ignored_plus_version_file
    # Mac OS X includes a file named +VERSION containing the tzdata version.
    
    Dir.mktmpdir('tzinfo_test') do |dir|
      FileUtils.touch(File.join(dir, 'zone.tab'))
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
      FileUtils.cp(File.join(@data_source.zoneinfo_dir, 'EST'), File.join(dir, 'EST'))
      
      File.open(File.join(dir, '+VERSION'), 'w') do |f|
        f.binmode
        f.write("2013a\n")
      end
      
      data_source = ZoneinfoDataSource.new(dir)
      assert_array_same_items(['EST'], data_source.timezone_identifiers)
    end
  end
  
  def test_timezone_identifiers_ignored_timeconfig_symlink
    # Slackware includes a symlink named timeconfig that points at /usr/sbin/timeconfig.

    Dir.mktmpdir('tzinfo_test_target') do |target_dir|
      target_path = File.join(target_dir, 'timeconfig')

      File.open(target_path, 'w') do |f|
        f.write("#!/bin/sh\n")
        f.write("#\n")
        f.write('# timeconfig         Slackware Linux timezone configuration utility.\n')
      end

      Dir.mktmpdir('tzinfo_test') do |dir|
        FileUtils.touch(File.join(dir, 'zone.tab'))
        FileUtils.touch(File.join(dir, 'iso3166.tab'))
        FileUtils.cp(File.join(@data_source.zoneinfo_dir, 'EST'), File.join(dir, 'EST'))

        symlink_path = File.join(dir, 'timeconfig')
        begin
          FileUtils.ln_s(target_path, symlink_path)
        rescue NotImplementedError, Errno::EACCES
          # Symlinks not supported on this platform, or permission denied
          # (administrative rights are required on Windows). Copy instead.
          FileUtils.cp(target_path, symlink_path)
        end

        data_source = ZoneinfoDataSource.new(dir)
        assert_array_same_items(['EST'], data_source.timezone_identifiers)
      end
    end
  end

  def test_timezone_identifiers_ignored_src_directory
    # Solaris includes a src directory containing the source timezone data files
    # from the tzdata distribution. These should be ignored.
    
    Dir.mktmpdir('tzinfo_test') do |dir|
      FileUtils.touch(File.join(dir, 'zone.tab'))
      FileUtils.touch(File.join(dir, 'iso3166.tab'))
      FileUtils.cp(File.join(@data_source.zoneinfo_dir, 'EST'), File.join(dir, 'EST'))
      
      src_dir = File.join(dir, 'src')
      FileUtils.mkdir(src_dir)
      
      File.open(File.join(src_dir, 'europe'), 'w') do |f|
        f.binmode
        f.write("Zone\tEurope/London\t0:00\tEU\tGMT/BST\n")
      end      
      
      data_source = ZoneinfoDataSource.new(dir)
      assert_array_same_items(['EST'], data_source.timezone_identifiers)
    end
  end
  
  def test_load_country_info
    info = @data_source.load_country_info('GB')
    assert_equal('GB', info.code)
    assert_equal('Britain (UK)', info.name)
  end
    
  def test_load_country_info_not_exist
    assert_raises(InvalidCountryCode) do
      @data_source.load_country_info('ZZ')
    end
  end
  
  def test_load_country_info_invalid
    assert_raises(InvalidCountryCode) do
      @data_source.load_country_info('../Countries/GB')
    end
  end
  
  def test_load_country_info_nil
    assert_raises(InvalidCountryCode) do
      @data_source.load_country_info(nil)
    end
  end
  
  def test_load_country_info_case
    assert_raises(InvalidCountryCode) do
      @data_source.load_country_info('gb')
    end
  end
  
  def test_load_country_info_tainted
    safe_test do
      code = 'NL'.dup.taint
      assert(code.tainted?)
      info = @data_source.load_country_info(code)
      assert_equal('NL', info.code)
      assert(code.tainted?)
    end
  end
  
  def test_load_country_info_tainted_and_frozen
    safe_test do
      info = @data_source.load_country_info('NL'.dup.taint.freeze)
      assert_equal('NL', info.code)
    end
  end
  
  def test_load_country_info_check_zones
    Dir.mktmpdir('tzinfo_test') do |dir|
      RubyCoreSupport.open_file(File.join(dir, 'iso3166.tab'), 'w', :external_encoding => 'UTF-8') do |iso3166|      
        iso3166.puts('# iso3166.tab')
        iso3166.puts('')
        iso3166.puts("FC\tFake Country")
        iso3166.puts("OC\tOther Country")
      end
      
      RubyCoreSupport.open_file(File.join(dir, 'zone.tab'), 'w', :external_encoding => 'UTF-8') do |zone|
        zone.puts('# zone.tab')
        zone.puts('')
        zone.puts("FC\t+513030-0000731\tFake/One\tDescription of one")
        zone.puts("FC\t+353916+1394441\tFake/Two\tAnother description")
        zone.puts("FC\t-2332-04637\tFake/Three\tThis is Three")
        zone.puts("OC\t+5005+01426\tOther/One")
      end
      
      data_source = ZoneinfoDataSource.new(dir)
      
      info = data_source.load_country_info('FC')
      assert_equal('FC', info.code)
      assert_equal('Fake Country', info.name)
      assert_equal(['Fake/One', 'Fake/Two', 'Fake/Three'], info.zone_identifiers)
      assert_equal(true, info.zone_identifiers.frozen?)
      assert_equal([
        CountryTimezone.new('Fake/One', Rational(6181, 120), Rational(-451, 3600), 'Description of one'),
        CountryTimezone.new('Fake/Two', Rational(32089, 900), Rational(503081, 3600), 'Another description'),
        CountryTimezone.new('Fake/Three', Rational(-353, 15), Rational(-2797, 60), 'This is Three')], info.zones)
      assert_equal(true, info.zones.frozen?)
      
      info = data_source.load_country_info('OC')
      assert_equal('OC', info.code)
      assert_equal('Other Country', info.name)
      assert_equal(['Other/One'], info.zone_identifiers)
      assert_equal(true, info.zone_identifiers.frozen?)
      assert_equal([CountryTimezone.new('Other/One', Rational(601, 12), Rational(433, 30))], info.zones)
      assert_equal(true, info.zones.frozen?)
    end
  end

  def test_load_country_info_check_zones_zone1970
    Dir.mktmpdir('tzinfo_test') do |dir|
      RubyCoreSupport.open_file(File.join(dir, 'iso3166.tab'), 'w', :external_encoding => 'UTF-8') do |iso3166|
        iso3166.puts('# iso3166.tab')
        iso3166.puts('')
        iso3166.puts("AC\tAnother Country")
        iso3166.puts("FC\tFake Country")
        iso3166.puts("OC\tOther Country")
      end

      # zone.tab will be ignored.
      RubyCoreSupport.open_file(File.join(dir, 'zone.tab'), 'w', :external_encoding => 'UTF-8') do |zone|
        zone.puts('# zone.tab')
        zone.puts('')
        zone.puts("FC\t+513030-0000731\tFake/One\tDescription of one")
        zone.puts("FC\t+353916+1394441\tFake/Two\tAnother description")
        zone.puts("FC\t-2332-04637\tFake/Three\tThis is Three")
        zone.puts("OC\t+5005+01426\tOther/One")
      end

      # zone1970.tab will be used.
      RubyCoreSupport.open_file(File.join(dir, 'zone1970.tab'), 'w', :external_encoding => 'UTF-8') do |zone|
        zone.puts('# zone1970.tab')
        zone.puts('')
        zone.puts("AC,OC\t+0000+00000\tMiddle/Another/One\tAnother's One")
        zone.puts("FC\t+513030-0000731\tFake/One\tDescription of one")
        zone.puts("FC,OC\t+353916+1394441\tFake/Two\tAnother description")
        zone.puts("FC,OC\t-2332-04637\tFake/Three\tThis is Three")
        zone.puts("OC\t+5005+01426\tOther/One")
        zone.puts("OC\t+5015+11426\tOther/Two")
      end

      data_source = ZoneinfoDataSource.new(dir)

      info = data_source.load_country_info('AC')
      assert_equal('AC', info.code)
      assert_equal('Another Country', info.name)
      assert_equal(['Middle/Another/One'], info.zone_identifiers)
      assert_equal(true, info.zone_identifiers.frozen?)
      assert_equal([CountryTimezone.new('Middle/Another/One', Rational(0, 1), Rational(0, 1), "Another's One")], info.zones)
      assert_equal(true, info.zones.frozen?)

      info = data_source.load_country_info('FC')
      assert_equal('FC', info.code)
      assert_equal('Fake Country', info.name)
      assert_equal(['Fake/One', 'Fake/Two', 'Fake/Three'], info.zone_identifiers)
      assert_equal(true, info.zone_identifiers.frozen?)
      assert_equal([
        CountryTimezone.new('Fake/One', Rational(6181, 120), Rational(-451, 3600), 'Description of one'),
        CountryTimezone.new('Fake/Two', Rational(32089, 900), Rational(503081, 3600), 'Another description'),
        CountryTimezone.new('Fake/Three', Rational(-353, 15), Rational(-2797, 60), 'This is Three')], info.zones)
      assert_equal(true, info.zones.frozen?)

      # Testing the ordering of zones. A zone can either be primary (country
      # code is the first in the first column), or secondary (country code is
      # not the first). Should return all the primaries first in the order they
      # appeared in the file, followed by all the secondaries in the order they
      # appeared in file.

      info = data_source.load_country_info('OC')
      assert_equal('OC', info.code)
      assert_equal('Other Country', info.name)
      assert_equal(['Other/One', 'Other/Two', 'Middle/Another/One', 'Fake/Two', 'Fake/Three'], info.zone_identifiers)
      assert_equal(true, info.zone_identifiers.frozen?)
      assert_equal([
        CountryTimezone.new('Other/One', Rational(601, 12), Rational( 433, 30)),
        CountryTimezone.new('Other/Two', Rational(201,  4), Rational(3433, 30)),
        CountryTimezone.new('Middle/Another/One', Rational(0, 1), Rational(0, 1), "Another's One"),
        CountryTimezone.new('Fake/Two', Rational(32089, 900), Rational(503081, 3600), 'Another description'),
        CountryTimezone.new('Fake/Three', Rational(-353, 15), Rational(-2797, 60), 'This is Three')], info.zones)
      assert_equal(true, info.zones.frozen?)
    end
  end
  
  def test_load_country_info_check_zones_solaris_tab_files
    # Solaris uses 5 columns instead of the usual 4 in zone_sun.tab.
    # An extra column before the comment gives an optional linked/alternate
    # timezone identifier (or '-' if not set).
    #
    # Additionally, there is a section at the end of the file for timezones
    # covering regions. These are given lower-case "country" codes. The timezone
    # identifier column refers to a continent instead of an identifier. These
    # lines will be ignored by TZInfo.
    
    Dir.mktmpdir('tzinfo_test') do |dir|
      tab_dir = File.join(dir, 'tab')
      FileUtils.mkdir(tab_dir)
    
      RubyCoreSupport.open_file(File.join(tab_dir, 'country.tab'), 'w', :external_encoding => 'UTF-8') do |country|
        country.puts('# country.tab')
        country.puts('# Solaris')
        country.puts("FC\tFake Country")
        country.puts("OC\tOther Country")
      end
      
      RubyCoreSupport.open_file(File.join(tab_dir, 'zone_sun.tab'), 'w', :external_encoding => 'UTF-8') do |zone_sun|
        zone_sun.puts('# zone_sun.tab')
        zone_sun.puts('# Solaris')
        zone_sun.puts('# Countries')
        zone_sun.puts("FC\t+513030-0000731\tFake/One\t-\tDescription of one")
        zone_sun.puts("FC\t+353916+1394441\tFake/Two\tFake/Alias/Two\tAnother description")
        zone_sun.puts("FC\t-2332-04637\tFake/Three\tFake/Alias/Three\tThis is Three")
        zone_sun.puts("OC\t+5005+01426\tOther/One\tOther/Linked/One")
        zone_sun.puts("OC\t+5015+01436\tOther/Two\t-")
        zone_sun.puts('# Regions')
        zone_sun.puts("ee\t+0000+00000\tEurope/\tEET")
        zone_sun.puts("me\t+0000+00000\tEurope/\tMET")
        zone_sun.puts("we\t+0000+00000\tEurope/\tWET")
      end
      
      data_source = ZoneinfoDataSource.new(dir)
      
      info = data_source.load_country_info('FC')
      assert_equal('FC', info.code)
      assert_equal('Fake Country', info.name)
      assert_equal(['Fake/One', 'Fake/Two', 'Fake/Three'], info.zone_identifiers)
      assert_equal(true, info.zone_identifiers.frozen?)
      assert_equal([
        CountryTimezone.new('Fake/One', Rational(6181, 120), Rational(-451, 3600), 'Description of one'),
        CountryTimezone.new('Fake/Two', Rational(32089, 900), Rational(503081, 3600), 'Another description'),
        CountryTimezone.new('Fake/Three', Rational(-353, 15), Rational(-2797, 60), 'This is Three')], info.zones)
      assert_equal(true, info.zones.frozen?)
      
      info = data_source.load_country_info('OC')
      assert_equal('OC', info.code)
      assert_equal('Other Country', info.name)
      assert_equal(['Other/One', 'Other/Two'], info.zone_identifiers)
      assert_equal(true, info.zone_identifiers.frozen?)
      assert_equal([
        CountryTimezone.new('Other/One', Rational(601, 12), Rational(433, 30)),
        CountryTimezone.new('Other/Two', Rational(201, 4), Rational(73, 5))], info.zones)
      assert_equal(true, info.zones.frozen?)
    end
  end
  
  def test_load_country_info_check_zones_alternate_iso3166_file
    Dir.mktmpdir('tzinfo_test') do |dir|
      zoneinfo_dir = File.join(dir, 'zoneinfo')
      tab_dir = File.join(dir, 'tab')
      FileUtils.mkdir(zoneinfo_dir)
      FileUtils.mkdir(tab_dir)
      
      tab_file = File.join(tab_dir, 'iso3166')
      RubyCoreSupport.open_file(tab_file, 'w', :external_encoding => 'UTF-8') do |iso3166|
        # Use the BSD 4 column format (alternate iso3166 is used on BSD).
        iso3166.puts("FC\tFCC\t001\tFake Country")
        iso3166.puts("OC\tOCC\t002\tOther Country")
      end
      
      RubyCoreSupport.open_file(File.join(zoneinfo_dir, 'zone.tab'), 'w', :external_encoding => 'UTF-8') do |zone|
        zone.puts("FC\t+513030-0000731\tFake/One\tDescription of one")
        zone.puts("FC\t+353916+1394441\tFake/Two\tAnother description")
        zone.puts("FC\t-2332-04637\tFake/Three\tThis is Three")
        zone.puts("OC\t+5005+01426\tOther/One")
      end
      
      data_source = ZoneinfoDataSource.new(zoneinfo_dir, tab_file)
      
      info = data_source.load_country_info('FC')
      assert_equal('FC', info.code)
      assert_equal('Fake Country', info.name)
      assert_equal(['Fake/One', 'Fake/Two', 'Fake/Three'], info.zone_identifiers)
      assert_equal(true, info.zone_identifiers.frozen?)
      assert_equal([
        CountryTimezone.new('Fake/One', Rational(6181, 120), Rational(-451, 3600), 'Description of one'),
        CountryTimezone.new('Fake/Two', Rational(32089, 900), Rational(503081, 3600), 'Another description'),
        CountryTimezone.new('Fake/Three', Rational(-353, 15), Rational(-2797, 60), 'This is Three')], info.zones)
      assert_equal(true, info.zones.frozen?)
      
      info = data_source.load_country_info('OC')
      assert_equal('OC', info.code)
      assert_equal('Other Country', info.name)
      assert_equal(['Other/One'], info.zone_identifiers)
      assert_equal(true, info.zone_identifiers.frozen?)
      assert_equal([CountryTimezone.new('Other/One', Rational(601, 12), Rational(433, 30))], info.zones)
      assert_equal(true, info.zones.frozen?)
    end
  end
  
  def test_load_country_info_four_column_iso31611
    # OpenBSD and FreeBSD use a 4 column iso3166.tab file that includes
    # alpha-3 and numeric-3 codes in addition to the alpha-2 and name in the
    # tz database version.
    
    Dir.mktmpdir('tzinfo_test') do |dir|
      RubyCoreSupport.open_file(File.join(dir, 'iso3166.tab'), 'w', :external_encoding => 'UTF-8') do |iso3166|
        iso3166.puts("FC\tFCC\t001\tFake Country")
        iso3166.puts("OC\tOCC\t002\tOther Country")
      end
      
      RubyCoreSupport.open_file(File.join(dir, 'zone.tab'), 'w', :external_encoding => 'UTF-8') do |zone|
        zone.puts("FC\t+513030-0000731\tFake/One\tDescription of one")
        zone.puts("OC\t+5005+01426\tOther/One")
      end
      
      data_source = ZoneinfoDataSource.new(dir)
      
      info = data_source.load_country_info('FC')
      assert_equal('FC', info.code)
      assert_equal('Fake Country', info.name)
      
      info = data_source.load_country_info('OC')
      assert_equal('OC', info.code)
      assert_equal('Other Country', info.name)
    end
  end

  def test_load_country_info_utf8
    # iso3166.tab is currently in ASCII (as of tzdata 2014f), but will be
    # changed to UTF-8 in the future.

    # zone.tab is in ASCII, with no plans to change. Since ASCII is a subset of
    # UTF-8, test that this is loaded in UTF-8 anyway.
    
    Dir.mktmpdir('tzinfo_test') do |dir|
      RubyCoreSupport.open_file(File.join(dir, 'iso3166.tab'), 'w', :external_encoding => 'UTF-8') do |iso3166|
        iso3166.puts("UT\tUnicode Test ✓")
      end
      
      RubyCoreSupport.open_file(File.join(dir, 'zone.tab'), 'w', :external_encoding => 'UTF-8') do |zone|
        zone.puts("UT\t+513030-0000731\tUnicode✓/One\tUnicode Description ✓")
      end
      
      data_source = ZoneinfoDataSource.new(dir)
      
      info = data_source.load_country_info('UT')
      assert_equal('UT', info.code)
      assert_equal('Unicode Test ✓', info.name)
      assert_equal(['Unicode✓/One'], info.zone_identifiers)
      assert_equal([CountryTimezone.new('Unicode✓/One', Rational(6181, 120), Rational(-451, 3600), 'Unicode Description ✓')], info.zones)
    end
  end

  def test_load_country_info_utf8_zone1970
    # iso3166.tab is currently in ASCII (as of tzdata 2014f), but will be
    # changed to UTF-8 in the future.

    # zone1970.tab is in UTF-8.

    Dir.mktmpdir('tzinfo_test') do |dir|
      RubyCoreSupport.open_file(File.join(dir, 'iso3166.tab'), 'w', :external_encoding => 'UTF-8') do |iso3166|
        iso3166.puts("UT\tUnicode Test ✓")
      end

      RubyCoreSupport.open_file(File.join(dir, 'zone1970.tab'), 'w', :external_encoding => 'UTF-8') do |zone|
        zone.puts("UT\t+513030-0000731\tUnicode✓/One\tUnicode Description ✓")
      end

      data_source = ZoneinfoDataSource.new(dir)

      info = data_source.load_country_info('UT')
      assert_equal('UT', info.code)
      assert_equal('Unicode Test ✓', info.name)
      assert_equal(['Unicode✓/One'], info.zone_identifiers)
      assert_equal([CountryTimezone.new('Unicode✓/One', Rational(6181, 120), Rational(-451, 3600), 'Unicode Description ✓')], info.zones)
    end
  end
  
  def test_country_codes
    file_codes = []
        
    RubyCoreSupport.open_file(File.join(@data_source.zoneinfo_dir, 'iso3166.tab'), 'r', :external_encoding => 'UTF-8', :internal_encoding => 'UTF-8') do |file|
      file.each_line do |line|
        line.chomp!
        file_codes << $1 if line =~ /\A([A-Z]{2})\t/
      end
    end
    
    codes = @data_source.country_codes
    assert_array_same_items(file_codes, codes)
    assert_equal(true, codes.frozen?)
  end
  
  def test_country_codes_four_column_iso3166
    # OpenBSD and FreeBSD use a 4 column iso3166.tab file that includes
    # alpha-3 and numeric-3 codes in addition to the alpha-2 and name in the
    # tz database version.
    
    Dir.mktmpdir('tzinfo_test') do |dir|
      RubyCoreSupport.open_file(File.join(dir, 'iso3166.tab'), 'w', :external_encoding => 'UTF-8') do |iso3166|
        iso3166.puts("FC\tFCC\t001\tFake Country")
        iso3166.puts("OC\tOCC\t002\tOther Country")
      end
      
      RubyCoreSupport.open_file(File.join(dir, 'zone.tab'), 'w', :external_encoding => 'UTF-8') do |zone|
        zone.puts("FC\t+513030-0000731\tFake/One\tDescription of one")
        zone.puts("OC\t+5005+01426\tOther/One")
      end
      
      data_source = ZoneinfoDataSource.new(dir)
      
      codes = data_source.country_codes
      assert_array_same_items(%w(FC OC), codes)
    end
  end
end
