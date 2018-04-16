require 'base64'

module Faraday
  class Request::BasicAuthentication < Request.load_middleware(:authorization)
    # Public
    def self.header(login, pass)
      value = Base64.encode64([login, pass].join(':'))
      value.gsub!("\n", '')
      super(:Basic, value)
    end
  end
end

