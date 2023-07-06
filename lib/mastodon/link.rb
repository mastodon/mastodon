module Mastodon
  module Link
    module_function

    def manual_url
    ENV.fetch('MANUAL_URL', nil)
    end
  end
end
