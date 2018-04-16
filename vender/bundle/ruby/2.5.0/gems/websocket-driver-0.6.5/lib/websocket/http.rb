module WebSocket
  module HTTP

    root = File.expand_path('../http', __FILE__)

    autoload :Headers,  root + '/headers'
    autoload :Request,  root + '/request'
    autoload :Response, root + '/response'

    def self.normalize_header(name)
      name.to_s.strip.downcase.gsub(/^http_/, '').gsub(/_/, '-')
    end

  end
end
