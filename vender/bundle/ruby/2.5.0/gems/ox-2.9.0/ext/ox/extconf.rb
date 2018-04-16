require 'mkmf'

extension_name = 'ox'
dir_config(extension_name)

parts = RUBY_DESCRIPTION.split(' ')
type = parts[0].downcase()
type = 'ree' if 'ruby' == type && RUBY_DESCRIPTION.include?('Ruby Enterprise Edition')
is_windows = RbConfig::CONFIG['host_os'] =~ /(mingw|mswin)/
platform = RUBY_PLATFORM
version = RUBY_VERSION.split('.')
puts ">>>>> Creating Makefile for #{type} version #{RUBY_VERSION} on #{platform} <<<<<"

dflags = {
  'RUBY_TYPE' => type,
  (type.upcase + '_RUBY') => nil,
  'RUBY_VERSION' => RUBY_VERSION,
  'RUBY_VERSION_MAJOR' => version[0],
  'RUBY_VERSION_MINOR' => version[1],
  'RUBY_VERSION_MICRO' => version[2],
  'HAS_RB_TIME_TIMESPEC' => ('ruby' == type && ('1.9.3' == RUBY_VERSION)) ? 1 : 0,
  #'HAS_RB_TIME_TIMESPEC' => ('ruby' == type && ('1.9.3' == RUBY_VERSION || '2' <= version[0])) ? 1 : 0,
  'HAS_TM_GMTOFF' => ('ruby' == type && (('1' == version[0] && '9' == version[1]) || '2' <= version[0]) && 
                      !(platform.include?('cygwin') || platform.include?('solaris') || platform.include?('linux') || RUBY_PLATFORM =~ /(win|w)32$/)) ? 1 : 0,
  'HAS_ENCODING_SUPPORT' => (('ruby' == type || 'rubinius' == type || 'macruby' == type) &&
                             (('1' == version[0] && '9' == version[1]) || '2' <= version[0])) ? 1 : 0,
  'HAS_ONIG' => (('ruby' == type || 'jruby' == type || 'rubinius' == type) &&
                 (('1' == version[0] && '9' == version[1]) || '2' <= version[0])) ? 1 : 0,
  'HAS_PRIVATE_ENCODING' => ('jruby' == type && '1' == version[0] && '9' == version[1]) ? 1 : 0,
  'HAS_NANO_TIME' => ('ruby' == type && ('1' == version[0] && '9' == version[1]) || '2' <= version[0]) ? 1 : 0,
  'HAS_RSTRUCT' => ('ruby' == type || 'ree' == type) ? 1 : 0,
  'HAS_IVAR_HELPERS' => ('ruby' == type && !is_windows && (('1' == version[0] && '9' == version[1]) || '2' <= version[0])) ? 1 : 0,
  'HAS_PROC_WITH_BLOCK' => ('ruby' == type && ('1' == version[0] && '9' == version[1]) || '2' <= version[0]) ? 1 : 0,
  'HAS_GC_GUARD' => ('jruby' != type && 'rubinius' != type) ? 1 : 0,
  'HAS_BIGDECIMAL' => ('jruby' != type) ? 1 : 0,
  'HAS_TOP_LEVEL_ST_H' => ('ree' == type || ('ruby' == type &&  '1' == version[0] && '8' == version[1])) ? 1 : 0,
  'NEEDS_UIO' => (RUBY_PLATFORM =~ /(win|w)32$/) ? 0 : 1,
  'HAS_DATA_OBJECT_WRAP' => ('ruby' == type && '2' == version[0] && '3' <= version[1]) ? 1 : 0,
  'UNIFY_FIXNUM_AND_BIGNUM' => ('ruby' == type && '2' == version[0] && '4' <= version[1]) ? 1 : 0,
}

if RUBY_PLATFORM =~ /(win|w)32$/ || RUBY_PLATFORM =~ /solaris2\.10/
  dflags['NEEDS_STPCPY'] = nil
end

if ['i386-darwin10.0.0', 'x86_64-darwin10.8.0'].include? RUBY_PLATFORM
  dflags['NEEDS_STPCPY'] = nil
  dflags['HAS_IVAR_HELPERS'] = 0 if ('ruby' == type && '1.9.1' == RUBY_VERSION)
elsif 'x86_64-linux' == RUBY_PLATFORM && '1.9.3' == RUBY_VERSION && '2011-10-30' == RUBY_RELEASE_DATE
  begin
    dflags['NEEDS_STPCPY'] = nil if `more /etc/issue`.include?('CentOS release 5.4')
  rescue Exception
  end
end

dflags.each do |k,v|
  if v.nil?
    $CPPFLAGS += " -D#{k}"
  else
    $CPPFLAGS += " -D#{k}=#{v}"
  end
end
$CPPFLAGS += ' -Wall'
#puts "*** $CPPFLAGS: #{$CPPFLAGS}"
create_makefile(extension_name)

%x{make clean}
