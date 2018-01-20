# frozen_string_literal: true

module PremailerWebpackStrategy
  def load(url)
    public_path_host = ENV['ASSET_HOST'] || ENV['LOCAL_DOMAIN']
    url = url.gsub(/\A\/\/#{public_path_host}/, '')

    if Webpacker.dev_server.running?
      url = File.join("#{Webpacker.dev_server.protocol}://#{Webpacker.dev_server.host_with_port}", url)
      HTTP.get(url).to_s
    else
      url = url[1..-1] if url.start_with?('/')
      File.read(Rails.root.join('public', url))
    end
  end

  module_function :load
end
