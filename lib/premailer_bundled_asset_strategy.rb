# frozen_string_literal: true

module PremailerBundledAssetStrategy
  def load(url)
    if ViteRuby.instance.dev_server_running?
      # Request from the dev server
      return unless url.start_with?("/#{ViteRuby.config.public_output_dir}/")

      headers = {}
      # Vite dev server wants this header for CSS files, otherwise it will respond with a JS file that inserts the CSS (to support hot reloading)
      headers['Accept'] = 'text/css' if url.end_with?('.scss', '.css')

      Net::HTTP.get(
        URI("#{ViteRuby.config.origin}#{url}"),
        headers
      ).presence
    else
      url = url.delete_prefix(Rails.configuration.action_controller.asset_host) if Rails.configuration.action_controller.asset_host.present?
      url = url.delete_prefix('/')
      path = Rails.public_path.join(url)
      return unless path.exist?

      path.read
    end
  rescue ViteRuby::MissingEntrypointError
    # If the path is not in the manifest, ignore it
  end

  module_function :load
end
