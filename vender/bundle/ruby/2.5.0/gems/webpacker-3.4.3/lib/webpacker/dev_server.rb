class Webpacker::DevServer
  # Configure dev server connection timeout (in seconds), default: 0.01
  # Webpacker.dev_server.connect_timeout = 1
  cattr_accessor(:connect_timeout) { 0.01 }

  delegate :config, to: :@webpacker

  def initialize(webpacker)
    @webpacker = webpacker
  end

  def running?
    if config.dev_server.present?
      Socket.tcp(host, port, connect_timeout: connect_timeout).close
      true
    else
      false
    end
  rescue
    false
  end

  def hot_module_replacing?
    case fetch(:hmr)
    when true, "true"
      true
    else
      false
    end
  end

  def host
    fetch(:host)
  end

  def port
    fetch(:port)
  end

  def https?
    case fetch(:https)
    when true, "true"
      true
    else
      false
    end
  end

  def protocol
    https? ? "https" : "http"
  end

  def host_with_port
    "#{host}:#{port}"
  end

  private
    def fetch(key)
      ENV["WEBPACKER_DEV_SERVER_#{key.upcase}"] || config.dev_server.fetch(key, defaults[key])
    end

    def defaults
      config.send(:defaults)[:dev_server]
    end
end
