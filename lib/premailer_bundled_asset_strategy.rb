# frozen_string_literal: true

module PremailerBundledAssetStrategy
  def load(url)
    asset_host = ENV['CDN_HOST'] || ENV['WEB_DOMAIN'] || ENV.fetch('LOCAL_DOMAIN', nil)

    if Webpacker.dev_server.running?
      asset_host = "#{Webpacker.dev_server.protocol}://#{Webpacker.dev_server.host_with_port}"
      url        = File.join(asset_host, url)
    end

    css = if url.start_with?('http')
            HTTP.get(url).to_s
          else
            url = url[1..] if url.start_with?('/')
            Rails.public_path.join(url).read
          end

    css.gsub(%r{url\(/}, "url(#{asset_host}/")
  end

  module_function :load
end
