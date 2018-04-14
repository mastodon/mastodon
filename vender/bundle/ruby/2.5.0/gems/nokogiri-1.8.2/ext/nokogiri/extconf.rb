# :stopdoc:
ENV['RC_ARCHS'] = '' if RUBY_PLATFORM =~ /darwin/

require 'mkmf'

ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

#
# functions
#
def windows?
  RbConfig::CONFIG['target_os'] =~ /mingw32|mswin/
end

def solaris?
  RbConfig::CONFIG['target_os'] =~ /solaris/
end

def darwin?
  RbConfig::CONFIG['target_os'] =~ /darwin/
end

def openbsd?
  RbConfig::CONFIG['target_os'] =~ /openbsd/
end

def nix?
  ! (windows? || solaris? || darwin?)
end

def sh_export_path path
  # because libxslt 1.1.29 configure.in uses AC_PATH_TOOL which treats ":"
  # as a $PATH separator, we need to convert windows paths from
  #
  #   C:/path/to/foo
  #
  # to
  #
  #   /C/path/to/foo
  #
  # which is sh-compatible, in order to find things properly during
  # configuration
  if windows?
    match = Regexp.new("^([A-Z]):(/.*)").match(path)
    if match && match.length == 3
      return File.join("/", match[1], match[2])
    end
  end
  path
end

def do_help
  print <<HELP
usage: ruby #{$0} [options]

    --disable-clean
        Do not clean out intermediate files after successful build.

    --disable-static
        Do not statically link bundled libraries.

    --with-iconv-dir=DIR
        Use the iconv library placed under DIR.

    --with-zlib-dir=DIR
        Use the zlib library placed under DIR.

    --use-system-libraries
        Use system libraries instead of building and using the bundled
        libraries.

    --with-xml2-dir=DIR / --with-xml2-config=CONFIG
    --with-xslt-dir=DIR / --with-xslt-config=CONFIG
    --with-exslt-dir=DIR / --with-exslt-config=CONFIG
        Use libxml2/libxslt/libexslt as specified.

    --enable-cross-build
        Do cross-build.
HELP
  exit! 0
end

def do_clean
  require 'pathname'
  require 'fileutils'

  root = Pathname(ROOT)
  pwd  = Pathname(Dir.pwd)

  # Skip if this is a development work tree
  unless (root + '.git').exist?
    message "Cleaning files only used during build.\n"

    # (root + 'tmp') cannot be removed at this stage because
    # nokogiri.so is yet to be copied to lib.

    # clean the ports build directory
    Pathname.glob(pwd.join('tmp', '*', 'ports')) do |dir|
      FileUtils.rm_rf(dir, verbose: true)
    end

    if enable_config('static')
      # ports installation can be safely removed if statically linked.
      FileUtils.rm_rf(root + 'ports', verbose: true)
    else
      FileUtils.rm_rf(root + 'ports' + 'archives', verbose: true)
    end
  end

  exit! 0
end

def package_config pkg, options={}
  package = pkg_config(pkg)
  return package if package

  begin
    require 'rubygems'
    gem 'pkg-config', (gem_ver='~> 1.1')
    require 'pkg-config' and message("Using pkg-config gem version #{PKGConfig::VERSION}\n")
  rescue LoadError
    message "pkg-config could not be used to find #{pkg}\nPlease install either `pkg-config` or the pkg-config gem per\n\n    gem install pkg-config -v #{gem_ver.inspect}\n\n"
  else
    return nil unless PKGConfig.have_package(pkg)

    cflags  = PKGConfig.cflags(pkg)
    ldflags = PKGConfig.libs_only_L(pkg)
    libs    = PKGConfig.libs_only_l(pkg)

    Logging::message "PKGConfig package configuration for %s\n", pkg
    Logging::message "cflags: %s\nldflags: %s\nlibs: %s\n\n", cflags, ldflags, libs

    [cflags, ldflags, libs]
  end
end

def nokogiri_try_compile
  try_compile "int main() {return 0;}", "", {werror: true}
end

def check_libxml_version version=nil
  source = if version.nil?
             <<-SRC
#include <libxml/xmlversion.h>
             SRC
           else
             version_int = sprintf "%d%2.2d%2.2d", *(version.split("."))
             <<-SRC
#include <libxml/xmlversion.h>
#if LIBXML_VERSION < #{version_int}
#error libxml2 is older than #{version}
#endif
             SRC
           end

  try_cpp source
end

def add_cflags(flags)
  print "checking if the C compiler accepts #{flags}... "
  with_cflags("#{$CFLAGS} #{flags}") do
    if nokogiri_try_compile
      puts 'yes'
      true
    else
      puts 'no'
      false
    end
  end
end

def preserving_globals
  values = [
    $arg_config,
    $CFLAGS, $CPPFLAGS,
    $LDFLAGS, $LIBPATH, $libs
  ].map(&:dup)
  yield
ensure
  $arg_config,
  $CFLAGS, $CPPFLAGS,
  $LDFLAGS, $LIBPATH, $libs =
    values
end

def asplode(lib)
  abort "-----\n#{lib} is missing.  Please locate mkmf.log to investigate how it is failing.\n-----"
end

def have_iconv?(using = nil)
  checking_for(using ? "iconv using #{using}" : 'iconv') do
    ['', '-liconv'].any? do |opt|
      preserving_globals do
        yield if block_given?

        try_link(<<-'SRC', opt)
#include <stdlib.h>
#include <iconv.h>

int main(void)
{
    iconv_t cd = iconv_open("", "");
    iconv(cd, NULL, NULL, NULL, NULL);
    return EXIT_SUCCESS;
}
        SRC
      end
    end
  end
end

def iconv_configure_flags
  # If --with-iconv-dir or --with-opt-dir is given, it should be
  # the first priority
  %w[iconv opt].each do |name|
    if (config = preserving_globals { dir_config(name) }).any? &&
        have_iconv?("--with-#{name}-* flags") { dir_config(name) }
      idirs, ldirs = config.map do |dirs|
        Array(dirs).flat_map do |dir|
          dir.split(File::PATH_SEPARATOR)
        end if dirs
      end

      return [
        '--with-iconv=yes',
        *("CPPFLAGS=#{idirs.map { |dir| '-I' + dir }.join(' ')}" if idirs),
        *("LDFLAGS=#{ldirs.map { |dir| '-L' + dir }.join(' ')}" if ldirs),
      ]
    end
  end

  if have_iconv?
    return ['--with-iconv=yes']
  end

  if (config = preserving_globals { package_config('libiconv') }) &&
     have_iconv?('pkg-config libiconv') { package_config('libiconv') }
    cflags, ldflags, libs = config

    return [
      '--with-iconv=yes',
      "CPPFLAGS=#{cflags}",
      "LDFLAGS=#{ldflags}",
      "LIBS=#{libs}",
    ]
  end

  asplode "libiconv"
end

# When using rake-compiler-dock on Windows, the underlying Virtualbox shared
# folders don't support symlinks, but libiconv expects it for a build on
# Linux. We work around this limitation by using the temp dir for cooking.
def chdir_for_build
  build_dir = ENV['RCD_HOST_RUBY_PLATFORM'].to_s =~ /mingw|mswin|cygwin/ ? '/tmp' : '.'
  Dir.chdir(build_dir) do
    yield
  end
end

def process_recipe(name, version, static_p, cross_p)
  MiniPortile.new(name, version).tap do |recipe|
    recipe.target = File.join(ROOT, "ports")
    # Prefer host_alias over host in order to use i586-mingw32msvc as
    # correct compiler prefix for cross build, but use host if not set.
    recipe.host = RbConfig::CONFIG["host_alias"].empty? ? RbConfig::CONFIG["host"] : RbConfig::CONFIG["host_alias"]
    recipe.patch_files = Dir[File.join(ROOT, "patches", name, "*.patch")].sort
    recipe.configure_options << "--libdir=#{File.join(recipe.path, "lib")}"

    yield recipe

    env = Hash.new do |hash, key|
      hash[key] = "#{ENV[key]}"  # (ENV[key].dup rescue '')
    end

    recipe.configure_options.flatten!

    recipe.configure_options.delete_if do |option|
      case option
      when /\A(\w+)=(.*)\z/
        env[$1] = $2
        true
      else
        false
      end
    end

    if static_p
      recipe.configure_options += [
        "--disable-shared",
        "--enable-static",
      ]
      env['CFLAGS'] = "-fPIC #{env['CFLAGS']}"
    else
      recipe.configure_options += [
        "--enable-shared",
        "--disable-static",
      ]
    end

    if cross_p
      recipe.configure_options += [
        "--target=#{recipe.host}",
        "--host=#{recipe.host}",
      ]
    end

    if RbConfig::CONFIG['target_cpu'] == 'universal'
      %w[CFLAGS LDFLAGS].each do |key|
        unless env[key].include?('-arch')
          env[key] += ' ' + RbConfig::CONFIG['ARCH_FLAG']
        end
      end
    end

    recipe.configure_options += env.map do |key, value|
      "#{key}=#{value}"
    end

    message <<-"EOS"
************************************************************************
IMPORTANT NOTICE:

Building Nokogiri with a packaged version of #{name}-#{version}#{'.' if recipe.patch_files.empty?}
    EOS

    unless recipe.patch_files.empty?
      message "with the following patches applied:\n"

      recipe.patch_files.each do |patch|
        message "\t- %s\n" % File.basename(patch)
      end
    end

    message <<-"EOS"

Team Nokogiri will keep on doing their best to provide security
updates in a timely manner, but if this is a concern for you and want
to use the system library instead; abort this installation process and
reinstall nokogiri as follows:

    gem install nokogiri -- --use-system-libraries
        [--with-xml2-config=/path/to/xml2-config]
        [--with-xslt-config=/path/to/xslt-config]

If you are using Bundler, tell it to use the option:

    bundle config build.nokogiri --use-system-libraries
    bundle install
    EOS

    message <<-"EOS" if name == 'libxml2'

Note, however, that nokogiri is not fully compatible with arbitrary
versions of libxml2 provided by OS/package vendors.
    EOS

    message <<-"EOS"
************************************************************************
    EOS

    checkpoint = "#{recipe.target}/#{recipe.name}-#{recipe.version}-#{recipe.host}.installed"
    unless File.exist?(checkpoint)
      chdir_for_build do
        recipe.cook
      end
      FileUtils.touch checkpoint
    end
    recipe.activate
  end
end

def lib_a(ldflag)
  case ldflag
  when /\A-l(.+)/
    "lib#{$1}.#{$LIBEXT}"
  end
end

def using_system_libraries?
  arg_config('--use-system-libraries', !!ENV['NOKOGIRI_USE_SYSTEM_LIBRARIES'])
end

#
# main
#

case
when arg_config('--help')
  do_help
when arg_config('--clean')
  do_clean
end

if openbsd? && !using_system_libraries?
  if `#{ENV['CC'] || '/usr/bin/cc'} -v 2>&1` !~ /clang/
    ENV['CC'] ||= find_executable('egcc') or
      abort "Please install gcc 4.9+ from ports using `pkg_add -v gcc`"
  end
  ENV['CFLAGS'] = "#{ENV['CFLAGS']} -I /usr/local/include"
end

RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC']
# use same c compiler for libxml and libxslt
ENV['CC'] = RbConfig::MAKEFILE_CONFIG['CC']

$LIBS << " #{ENV["LIBS"]}"

# Read CFLAGS from ENV and make sure compiling works.
add_cflags(ENV["CFLAGS"])

if windows?
  $CFLAGS << " -DXP_WIN -DXP_WIN32 -DUSE_INCLUDED_VASPRINTF"
end

if solaris?
  $CFLAGS << " -DUSE_INCLUDED_VASPRINTF"
end

if darwin?
  # Let Apple LLVM/clang 5.1 ignore unknown compiler flags
  add_cflags("-Wno-error=unused-command-line-argument-hard-error-in-future")
end

if nix?
  $CFLAGS << " -g -DXP_UNIX"
end

if RUBY_PLATFORM =~ /mingw/i
  # Work around a character escaping bug in MSYS by passing an arbitrary
  # double quoted parameter to gcc. See https://sourceforge.net/p/mingw/bugs/2142
  $CPPFLAGS << ' "-Idummypath"'
end

if RbConfig::MAKEFILE_CONFIG['CC'] =~ /gcc/
  $CFLAGS << " -O3" unless $CFLAGS[/-O\d/]
  $CFLAGS << " -Wall -Wcast-qual -Wwrite-strings -Wconversion -Wmissing-noreturn -Winline"
end

case
when using_system_libraries?
  message "Building nokogiri using system libraries.\n"

  dir_config('zlib')

  # Using system libraries means we rely on the system libxml2 with
  # regard to the iconv support.

  dir_config('xml2').any?  or package_config('libxml-2.0')
  dir_config('xslt').any?  or package_config('libxslt')
  dir_config('exslt').any? or package_config('libexslt')

  check_libxml_version or abort "ERROR: cannot discover where libxml2 is located on your system. please make sure `pkg-config` is installed."
  check_libxml_version("2.6.21") or abort "ERROR: libxml2 version 2.6.21 or later is required!"
  check_libxml_version("2.9.3") or warn "WARNING: libxml2 version 2.9.3 or later is highly recommended, but proceeding anyway."

else
  message "Building nokogiri using packaged libraries.\n"

  # The gem version constraint in the Rakefile is not respected at install time.
  # Keep this version in sync with the one in the Rakefile !
  require 'rubygems'
  gem 'mini_portile2', '~> 2.3.0'
  require 'mini_portile2'
  message "Using mini_portile version #{MiniPortile::VERSION}\n"

  require 'yaml'

  static_p = enable_config('static', true) or
    message "Static linking is disabled.\n"

  dir_config('zlib')

  dependencies = YAML.load_file(File.join(ROOT, "dependencies.yml"))

  cross_build_p = enable_config("cross-build")
  if cross_build_p || windows?
    zlib_recipe = process_recipe("zlib", dependencies["zlib"]["version"], static_p, cross_build_p) do |recipe|
      recipe.files = [{
          url: "http://zlib.net/fossils/#{recipe.name}-#{recipe.version}.tar.gz",
          sha256: dependencies["zlib"]["sha256"]
        }]
      class << recipe
        attr_accessor :cross_build_p

        def configure
          Dir.chdir work_path do
            mk = File.read 'win32/Makefile.gcc'
            File.open 'win32/Makefile.gcc', 'wb' do |f|
              f.puts "BINARY_PATH = #{path}/bin"
              f.puts "LIBRARY_PATH = #{path}/lib"
              f.puts "INCLUDE_PATH = #{path}/include"
              mk.sub!(/^PREFIX\s*=\s*$/, "PREFIX = #{host}-") if cross_build_p
              f.puts mk
            end
          end
        end

        def configured?
          Dir.chdir work_path do
            !! (File.read('win32/Makefile.gcc') =~ /^BINARY_PATH/)
          end
        end

        def compile
          execute "compile", "make -f win32/Makefile.gcc"
        end

        def install
          execute "install", "make -f win32/Makefile.gcc install"
        end
      end
      recipe.cross_build_p = cross_build_p
    end

    libiconv_recipe = process_recipe("libiconv", dependencies["libiconv"]["version"], static_p, cross_build_p) do |recipe|
      recipe.files = [{
          url: "http://ftp.gnu.org/pub/gnu/libiconv/#{recipe.name}-#{recipe.version}.tar.gz",
          sha256: dependencies["libiconv"]["sha256"]
        }]
      recipe.configure_options += [
        "CPPFLAGS=-Wall",
        "CFLAGS=-O2 -g",
        "CXXFLAGS=-O2 -g",
        "LDFLAGS="
      ]
    end
  else
    if darwin? && !have_header('iconv.h')
      abort <<'EOM'.chomp
-----
The file "iconv.h" is missing in your build environment,
which means you haven't installed Xcode Command Line Tools properly.

To install Command Line Tools, try running `xcode-select --install` on
terminal and follow the instructions.  If it fails, open Xcode.app,
select from the menu "Xcode" - "Open Developer Tool" - "More Developer
Tools" to open the developer site, download the installer for your OS
version and run it.
-----
EOM
    end
  end

  unless windows?
    preserving_globals {
      have_library('z', 'gzdopen', 'zlib.h')
    } or abort 'zlib is missing; necessary for building libxml2'
  end

  libxml2_recipe = process_recipe("libxml2", dependencies["libxml2"]["version"], static_p, cross_build_p) do |recipe|
    recipe.files = [{
        url: "http://xmlsoft.org/sources/#{recipe.name}-#{recipe.version}.tar.gz",
        sha256: dependencies["libxml2"]["sha256"]
      }]
    recipe.configure_options += [
      "--without-python",
      "--without-readline",
      *(zlib_recipe ? ["--with-zlib=#{zlib_recipe.path}", "CFLAGS=-I#{zlib_recipe.path}/include"] : []),
      *(libiconv_recipe ? "--with-iconv=#{libiconv_recipe.path}" : iconv_configure_flags),
      "--with-c14n",
      "--with-debug",
      "--with-threads"
    ]
  end

  libxslt_recipe = process_recipe("libxslt", dependencies["libxslt"]["version"], static_p, cross_build_p) do |recipe|
    recipe.files = [{
        url: "http://xmlsoft.org/sources/#{recipe.name}-#{recipe.version}.tar.gz",
        sha256: dependencies["libxslt"]["sha256"]
      }]
    recipe.configure_options += [
      "--without-python",
      "--without-crypto",
      "--with-debug",
      "--with-libxml-prefix=#{sh_export_path(libxml2_recipe.path)}"
    ]
  end

  $CFLAGS << ' ' << '-DNOKOGIRI_USE_PACKAGED_LIBRARIES'
  $LIBPATH = ["#{zlib_recipe.path}/lib"] | $LIBPATH if zlib_recipe
  $LIBPATH = ["#{libiconv_recipe.path}/lib"] | $LIBPATH if libiconv_recipe

  have_lzma = preserving_globals {
    have_library('lzma')
  }

  $libs = $libs.shellsplit.tap do |libs|
    [libxml2_recipe, libxslt_recipe].each do |recipe|
      libname = recipe.name[/\Alib(.+)\z/, 1]
      File.join(recipe.path, "bin", "#{libname}-config").tap do |config|
        # call config scripts explicit with 'sh' for compat with Windows
        $CPPFLAGS = `sh #{config} --cflags`.strip << ' ' << $CPPFLAGS
        `sh #{config} --libs`.strip.shellsplit.each do |arg|
          case arg
          when /\A-L(.+)\z/
            # Prioritize ports' directories
            if $1.start_with?(ROOT + '/')
              $LIBPATH = [$1] | $LIBPATH
            else
              $LIBPATH = $LIBPATH | [$1]
            end
          when /\A-l./
            libs.unshift(arg)
          else
            $LDFLAGS << ' ' << arg.shellescape
          end
        end
      end

      # Defining a macro that expands to a C string; double quotes are significant.
      $CPPFLAGS << ' ' << "-DNOKOGIRI_#{recipe.name.upcase}_PATH=\"#{recipe.path}\"".inspect
      $CPPFLAGS << ' ' << "-DNOKOGIRI_#{recipe.name.upcase}_PATCHES=\"#{recipe.patch_files.map { |path| File.basename(path) }.join(' ')}\"".inspect

      case libname
      when 'xml2'
        # xslt-config --libs or pkg-config libxslt --libs does not include
        # -llzma, so we need to add it manually when linking statically.
        if static_p && have_lzma
          # Add it at the end; GH #988
          libs << '-llzma'
        end
      when 'xslt'
        # xslt-config does not have a flag to emit options including
        # -lexslt, so add it manually.
        libs.unshift('-lexslt')
      end
    end
  end.shelljoin

  if static_p
    $libs = $libs.shellsplit.map do |arg|
      case arg
      when '-lxml2'
        File.join(libxml2_recipe.path, 'lib', lib_a(arg))
      when '-lxslt', '-lexslt'
        File.join(libxslt_recipe.path, 'lib', lib_a(arg))
      else
        arg
      end
    end.shelljoin
  end
end

{
  "xml2"  => ['xmlParseDoc',            'libxml/parser.h'],
  "xslt"  => ['xsltParseStylesheetDoc', 'libxslt/xslt.h'],
  "exslt" => ['exsltFuncRegister',      'libexslt/exslt.h'],
}.each do |lib, (func, header)|
  have_func(func, header) ||
  have_library(lib, func, header) ||
  have_library("lib#{lib}", func, header) or
    asplode("lib#{lib}")
end

have_func('xmlHasFeature') or abort "xmlHasFeature() is missing."
have_func('xmlFirstElementChild')
have_func('xmlRelaxNGSetParserStructuredErrors')
have_func('xmlRelaxNGSetParserStructuredErrors')
have_func('xmlRelaxNGSetValidStructuredErrors')
have_func('xmlSchemaSetValidStructuredErrors')
have_func('xmlSchemaSetParserStructuredErrors')

create_makefile('nokogiri/nokogiri')

if enable_config('clean', true)
  # Do not clean if run in a development work tree.
  File.open('Makefile', 'at') do |mk|
    mk.print <<EOF
all: clean-ports

clean-ports: $(DLLIB)
	-$(Q)$(RUBY) $(srcdir)/extconf.rb --clean --#{static_p ? 'enable' : 'disable'}-static
EOF
  end
end

# :startdoc:
