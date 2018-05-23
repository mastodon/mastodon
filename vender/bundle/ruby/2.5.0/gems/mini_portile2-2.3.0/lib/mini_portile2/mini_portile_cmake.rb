require 'mini_portile2/mini_portile'

class MiniPortileCMake < MiniPortile
  def configure_prefix
    "-DCMAKE_INSTALL_PREFIX=#{File.expand_path(port_path)}"
  end

  def configure_defaults
    if MiniPortile.windows?
      ['-G "NMake Makefiles"']
    else
      []
    end
  end

  def configure
    return if configured?

    cache_file = File.join(tmp_path, 'configure.options_cache')
    File.open(cache_file, "w") { |f| f.write computed_options.to_s }

    execute('configure', %w(cmake) + computed_options + ["."])
  end

  def configured?
    configure = File.join(work_path, 'configure')
    makefile  = File.join(work_path, 'CMakefile')
    cache_file  = File.join(tmp_path, 'configure.options_cache')

    stored_options  = File.exist?(cache_file) ? File.read(cache_file) : ""
    current_options = computed_options.to_s

    (current_options == stored_options) && newer?(makefile, configure)
  end

  def make_cmd
    return "nmake" if MiniPortile.windows?
    super
  end
end
