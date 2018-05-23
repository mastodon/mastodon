class Webpacker::Configuration
  delegate :root_path, :config_path, :env, to: :@webpacker

  def initialize(webpacker)
    @webpacker = webpacker
  end

  def refresh
    @data = load
  end

  def dev_server
    fetch(:dev_server)
  end

  def compile?
    fetch(:compile)
  end

  def source_path
    root_path.join(fetch(:source_path))
  end

  def resolved_paths
    fetch(:resolved_paths)
  end

  def resolved_paths_globbed
    resolved_paths.map { |p| "#{p}/**/*" }
  end

  def source_entry_path
    source_path.join(fetch(:source_entry_path))
  end

  def public_path
    root_path.join("public")
  end

  def public_output_path
    public_path.join(fetch(:public_output_path))
  end

  def public_manifest_path
    public_output_path.join("manifest.json")
  end

  def cache_manifest?
    fetch(:cache_manifest)
  end

  def cache_path
    root_path.join(fetch(:cache_path))
  end

  def extensions
    fetch(:extensions)
  end

  private
    def fetch(key)
      data.fetch(key, defaults[key])
    end

    def data
      @data ||= load
    end

    def load
      YAML.load(config_path.read)[env].deep_symbolize_keys

    rescue Errno::ENOENT => e
      raise "Webpacker configuration file not found #{config_path}. " \
            "Please run rails webpacker:install " \
            "Error: #{e.message}"

    rescue Psych::SyntaxError => e
      raise "YAML syntax error occurred while parsing #{config_path}. " \
            "Please note that YAML must be consistently indented using spaces. Tabs are not allowed. " \
            "Error: #{e.message}"
    end

    def defaults
      @defaults ||= \
        HashWithIndifferentAccess.new(YAML.load_file(File.expand_path("../../install/config/webpacker.yml", __FILE__))[env])
    end
end
