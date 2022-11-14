module RswagHelper
  module Include
    def rswag_parse_body(response)
      JSON.parse(response.body, symbolize_names: false)
    end

    def rswag_parse_body_sym(response)
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end

RSpec.configure do |config|
  config.include RswagHelper::Include, type: :request
end
