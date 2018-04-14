# Copyright 2008-2018 Kouhei Sutou <kou@cozmixng.org>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

begin
  require "pkg-config/version"
rescue LoadError
end

require "rbconfig"

require 'shellwords'
require 'English'
require 'pathname'

class PackageConfig
  SEPARATOR = File::PATH_SEPARATOR

  class << self
    @native_pkg_config = nil
    def native_pkg_config
      @native_pkg_config ||= guess_native_pkg_config
    end

    @custom_override_variables = nil
    def custom_override_variables
      @custom_override_variables ||= with_config("override-variables", "")
    end

    def clear_configure_args_cache
      @native_pkg_config = nil
      @custom_override_variables = nil
    end

    private
    def with_config(config, default=nil)
      if defined?(super)
        super
      else
        default
      end
    end

    def guess_native_pkg_config
      pkg_config = with_config("pkg-config", ENV["PKG_CONFIG"] || "pkg-config")
      pkg_config = Pathname.new(pkg_config)
      unless pkg_config.absolute?
        found_pkg_config = search_pkg_config_from_path(pkg_config)
        pkg_config = found_pkg_config if found_pkg_config
      end
      unless pkg_config.absolute?
        found_pkg_config = search_pkg_config_by_dln_find_exe(pkg_config)
        pkg_config = found_pkg_config if found_pkg_config
      end
      pkg_config
    end

    def search_pkg_config_from_path(pkg_config)
      (ENV["PATH"] || "").split(SEPARATOR).each do |path|
        try_pkg_config = Pathname(path) + pkg_config
        return try_pkg_config if try_pkg_config.exist?
      end
      nil
    end

    def search_pkg_config_by_dln_find_exe(pkg_config)
      begin
        require "dl/import"
      rescue LoadError
        return nil
      end
      dln = Module.new
      dln.module_eval do
        if DL.const_defined?(:Importer)
          extend DL::Importer
        else
          extend DL::Importable
        end
        begin
          dlload RbConfig::CONFIG["LIBRUBY"]
        rescue RuntimeError
          return nil if $!.message == "unknown error"
          return nil if /: image not found\z/ =~ $!.message
          raise
        rescue DL::DLError
          return nil
        end
        begin
          extern "const char *dln_find_exe(const char *, const char *)"
        rescue DL::DLError
          return nil
        end
      end
      path = dln.dln_find_exe(pkg_config.to_s, nil)
      if path.nil? or path.size.zero?
        nil
      else
        Pathname(path.to_s)
      end
    end
  end

  attr_reader :paths
  attr_accessor :msvc_syntax
  def initialize(name, options={})
    @name = name
    @options = options
    path = @options[:path] || ENV["PKG_CONFIG_PATH"]
    @paths = [path, guess_default_path].compact.join(SEPARATOR).split(SEPARATOR)
    @paths.unshift(*(@options[:paths] || []))
    @paths = normalize_paths(@paths)
    @msvc_syntax = @options[:msvc_syntax]
    @variables = @declarations = nil
    override_variables = self.class.custom_override_variables
    @override_variables = parse_override_variables(override_variables)
    default_override_variables = @options[:override_variables] || {}
    @override_variables = default_override_variables.merge(@override_variables)
  end

  def exist?
    not pc_path.nil?
  end

  def requires
    parse_requires(declaration("Requires"))
  end

  def requires_private
    parse_requires(declaration("Requires.private"))
  end

  def cflags
    path_flags, other_flags = collect_cflags
    (other_flags + path_flags).join(" ")
  end

  def cflags_only_I
    collect_cflags[0].join(" ")
  end

  def cflags_only_other
    collect_cflags[1].join(" ")
  end

  def libs
    path_flags, other_flags = collect_libs
    (path_flags + other_flags).join(" ")
  end

  def libs_only_l
    collect_libs[1].find_all do |arg|
      if @msvc_syntax
        /\.lib\z/ =~ arg
      else
        /\A-l/ =~ arg
      end
    end.join(" ")
  end

  def libs_only_L
    collect_libs[0].find_all do |arg|
      if @msvc_syntax
        /\A\/libpath:/ =~ arg
      else
        /\A-L/ =~ arg
      end
    end.join(" ")
  end

  def version
    declaration("Version")
  end

  def description
    declaration("Description")
  end

  def variable(name)
    parse_pc if @variables.nil?
    expand_value(@override_variables[name] || @variables[name])
  end

  def declaration(name)
    parse_pc if @declarations.nil?
    expand_value(@declarations[name])
  end

  def pc_path
    @paths.each do |path|
      _pc_path = File.join(path, "#{@name}.pc")
      return _pc_path if File.exist?(_pc_path)
    end
    nil
  end

  private
  def collect_cflags
    cflags_set = [declaration("Cflags")]
    cflags_set += required_packages.collect do |package|
      self.class.new(package, @options).cflags
    end
    cflags_set += private_required_packages.collect do |package|
      self.class.new(package, @options).cflags
    end
    all_cflags = normalize_cflags(Shellwords.split(cflags_set.join(" ")))
    path_flags, other_flags = all_cflags.partition {|flag| /\A-I/ =~ flag}
    path_flags = normalize_path_flags(path_flags, "-I")
    path_flags = remove_duplicated_include_paths(path_flags)
    path_flags = path_flags.reject do |flag|
      flag == "-I/usr/include"
    end
    if @msvc_syntax
      path_flags = path_flags.collect do |flag|
        flag.gsub(/\A-I/, "/I")
      end
    end
    [path_flags, other_flags]
  end

  def normalize_path_flags(path_flags, flag_option)
    path_flags.collect do |path_flag|
      path = path_flag.sub(flag_option, "")
      prefix = ""
      case RUBY_PLATFORM
      when "x86-mingw32"
        prefix = Dir.glob("c:/msys{32,64,*}").first
      when "x64-mingw32"
        prefix = Dir.glob("c:/msys{64,*}").first
      end
      if /\A[a-z]:/i === path
        "#{flag_option}#{path}"
      else
        "#{flag_option}#{prefix}#{path}"
      end
    end
  end

  def normalize_cflags(cflags)
    normalized_cflags = []
    enumerator = cflags.to_enum
    begin
      loop do
        cflag = enumerator.next
        normalized_cflags << cflag
        case cflag
        when "-I"
          normalized_cflags << enumerator.next
        end
      end
    rescue StopIteration
    end
    normalized_cflags
  end

  def remove_duplicated_include_paths(path_flags)
    path_flags.uniq
  end

  def collect_libs
    all_libs = required_packages.collect do |package|
      self.class.new(package, @options).libs
    end
    all_libs = [declaration("Libs")] + all_libs
    all_libs = all_libs.join(" ").gsub(/-([Ll]) /, '\1').split.uniq
    path_flags, other_flags = all_libs.partition {|flag| /\A-L/ =~ flag}
    path_flags = normalize_path_flags(path_flags, "-L")
    path_flags = path_flags.reject do |flag|
      /\A-L\/usr\/lib(?:64|x32)?\z/ =~ flag
    end
    if @msvc_syntax
      path_flags = path_flags.collect do |flag|
        flag.gsub(/\A-L/, "/libpath:")
      end
      other_flags = other_flags.collect do |flag|
        if /\A-l/ =~ flag
          "#{$POSTMATCH}.lib"
        else
          flag
        end
      end
    end
    [path_flags, other_flags]
  end

  IDENTIFIER_RE = /[a-zA-Z\d_\.]+/
  def parse_pc
    raise ".pc for #{@name} doesn't exist." unless exist?
    @variables = {}
    @declarations = {}
    File.open(pc_path) do |input|
      input.each_line do |line|
        line = line.gsub(/#.*/, '').strip
        next if line.empty?
        case line
        when /^(#{IDENTIFIER_RE})=/
          @variables[$1] = $POSTMATCH.strip
        when /^(#{IDENTIFIER_RE}):/
          @declarations[$1] = $POSTMATCH.strip
        end
      end
    end
  end

  def parse_requires(requires)
    return [] if requires.nil?
    requires_without_version = requires.gsub(/[<>]?=\s*[\d.]+\s*/, '')
    requires_without_version.split(/[,\s]+/)
  end

  def parse_override_variables(override_variables)
    variables = {}
    override_variables.split(",").each do |variable|
      name, value = variable.split("=", 2)
      variables[name] = value
    end
    variables
  end

  def expand_value(value)
    return nil if value.nil?
    value.gsub(/\$\{(#{IDENTIFIER_RE})\}/) do
      variable($1)
    end
  end

  def guess_default_path
    arch_depended_path = Dir.glob("/usr/lib/*/pkgconfig")
    default_paths = [
      "/usr/local/lib64/pkgconfig",
      "/usr/local/libx32/pkgconfig",
      "/usr/local/lib/pkgconfig",
      "/usr/local/libdata/pkgconfig",
      "/usr/local/share/pkgconfig",
      "/opt/local/lib/pkgconfig",
      *arch_depended_path,
      "/usr/lib64/pkgconfig",
      "/usr/libx32/pkgconfig",
      "/usr/lib/pkgconfig",
      "/usr/libdata/pkgconfig",
      "/usr/X11R6/lib/pkgconfig",
      "/usr/X11R6/share/pkgconfig",
      "/usr/X11/lib/pkgconfig",
      "/opt/X11/lib/pkgconfig",
      "/usr/share/pkgconfig",
    ]
    case RUBY_PLATFORM
    when "x86-mingw32"
      default_paths.concat(Dir.glob("c:/msys*/mingw32/lib/pkgconfig"))
    when "x64-mingw32"
      default_paths.concat(Dir.glob("c:/msys*/mingw64/lib/pkgconfig"))
    end
    libdir = ENV["PKG_CONFIG_LIBDIR"]
    default_paths.unshift(libdir) if libdir

    pkg_config = self.class.native_pkg_config
    return default_paths.join(SEPARATOR) unless pkg_config.absolute?

    pkg_config_prefix = pkg_config.parent.parent
    pkg_config_arch_depended_paths =
      Dir.glob((pkg_config_prefix + "lib/*/pkgconfig").to_s)
    paths = []
    paths.concat(pkg_config_arch_depended_paths)
    paths << (pkg_config_prefix + "lib64/pkgconfig").to_s
    paths << (pkg_config_prefix + "libx32/pkgconfig").to_s
    paths << (pkg_config_prefix + "lib/pkgconfig").to_s
    paths << (pkg_config_prefix + "libdata/pkgconfig").to_s
    if /-darwin\d[\d\.]*\z/ =~ RUBY_PLATFORM and
        /\A(\d+\.\d+)/ =~ `sw_vers -productVersion`
      mac_os_version = $1
      homebrew_repository_candidates = []
      brew_path = pkg_config_prefix + "bin" + "brew"
      if brew_path.exist?
        escaped_brew_path = Shellwords.escape(brew_path.to_s)
        homebrew_repository = `#{escaped_brew_path} --repository`.chomp
        homebrew_repository_candidates << Pathname.new(homebrew_repository)
      else
        homebrew_repository_candidates << pkg_config_prefix + "Homebrew"
        homebrew_repository_candidates << pkg_config_prefix
      end
      homebrew_repository_candidates.each do |candidate|
        path = candidate + "Library/Homebrew/os/mac/pkgconfig/#{mac_os_version}"
        paths << path.to_s if path.exist?
      end
    end
    paths.concat(default_paths)
    paths.join(SEPARATOR)
  end

  def required_packages
    requires.reject do |package|
      @name == package
    end.uniq
  end

  def private_required_packages
    requires_private.reject do |package|
      @name == package
    end.uniq
  end

  def all_required_packages
    (requires_private + requires.reverse).reject do |package|
      @name == package
    end.uniq
  end

  def normalize_paths(paths)
    paths.reject do |path|
      path.empty? or !File.exist?(path)
    end
  end
end

module PKGConfig
  @@paths = []
  @@override_variables = {}

  module_function
  def add_path(path)
    @@paths << path
  end

  def set_override_variable(key, value)
    @@override_variables[key] = value
  end

  def msvc?
    /mswin/.match(RUBY_PLATFORM) and /^cl\b/.match(RbConfig::CONFIG['CC'])
  end

  def package_config(package)
    PackageConfig.new(package,
                      :msvc_syntax => msvc?,
                      :override_variables => @@override_variables,
                      :paths => @@paths)
  end

  def exist?(pkg)
    package_config(pkg).exist?
  end

  def libs(pkg)
    package_config(pkg).libs
  end

  def libs_only_l(pkg)
    package_config(pkg).libs_only_l
  end

  def libs_only_L(pkg)
    package_config(pkg).libs_only_L
  end

  def cflags(pkg)
    package_config(pkg).cflags
  end

  def cflags_only_I(pkg)
    package_config(pkg).cflags_only_I
  end

  def cflags_only_other(pkg)
    package_config(pkg).cflags_only_other
  end

  def modversion(pkg)
    package_config(pkg).version
  end

  def description(pkg)
    package_config(pkg).description
  end

  def variable(pkg, name)
    package_config(pkg).variable(name)
  end

  def check_version?(pkg, major=0, minor=0, micro=0)
    return false unless exist?(pkg)
    ver = modversion(pkg).split(".").collect {|item| item.to_i}
    (0..2).each {|i| ver[i] = 0 unless ver[i]}

    (ver[0] > major ||
     (ver[0] == major && ver[1] > minor) ||
     (ver[0] == major && ver[1] == minor &&
      ver[2] >= micro))
  end

  def have_package(pkg, major=nil, minor=0, micro=0)
    message = "#{pkg}"
    unless major.nil?
      message << " version (>= #{major}.#{minor}.#{micro})"
    end
    major ||= 0
    enough_version = checking_for(checking_message(message)) do
      check_version?(pkg, major, minor, micro)
    end
    if enough_version
      libraries = libs_only_l(pkg)
      dldflags = libs(pkg)
      dldflags = (Shellwords.shellwords(dldflags) -
                  Shellwords.shellwords(libraries))
      dldflags = dldflags.map {|s| /\s/ =~ s ? "\"#{s}\"" : s }.join(' ')
      $libs   += ' ' + libraries
      if /mswin/ =~ RUBY_PLATFORM
        $DLDFLAGS += ' ' + dldflags
      else
        $LDFLAGS += ' ' + dldflags
      end
      $CFLAGS += ' ' + cflags_only_other(pkg)
      $CXXFLAGS += ' ' + cflags_only_other(pkg)
      $INCFLAGS += ' ' + cflags_only_I(pkg)
    end
    enough_version
  end
end
