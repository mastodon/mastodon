require 'net/http'
require 'net/https'
require 'nokogiri'

module OmniAuth
  module Strategies
    class CAS
      class ServiceTicketValidator
        VALIDATION_REQUEST_HEADERS = { 'Accept' => '*/*' }

        # Build a validator from a +configuration+, a
        # +return_to+ URL, and a +ticket+.
        #
        # @param [Hash] options the OmniAuth Strategy options
        # @param [String] return_to_url the URL of this CAS client service
        # @param [String] ticket the service ticket to validate
        def initialize(strategy, options, return_to_url, ticket)
          @options = options
          @uri = URI.parse(strategy.service_validate_url(return_to_url, ticket))
        end

        # Executes a network request to process the CAS Service Response
        def call
          @response_body = get_service_response_body
          @success_body = find_authentication_success(@response_body)
          self
        end

        # Request validation of the ticket from the CAS server's
        # serviceValidate (CAS 2.0) function.
        #
        # Swallows all XML parsing errors (and returns +nil+ in those cases).
        #
        # @return [Hash, nil] a user information hash if the response is valid; +nil+ otherwise.
        #
        # @raise any connection errors encountered.
        def user_info
          parse_user_info(@success_body)
        end

      private

        # turns an `<cas:authenticationSuccess>` node into a Hash;
        # returns nil if given nil
        def parse_user_info(node)
          return nil if node.nil?
          {}.tap do |hash|
            node.children.each do |e|
              node_name = e.name.sub(/^cas:/, '')
              unless e.kind_of?(Nokogiri::XML::Text) || node_name == 'proxies'
                # There are no child elements
                if e.element_children.count == 0
                  hash[node_name] = e.content
                elsif e.element_children.count
                  # JASIG style extra attributes
                  if node_name == 'attributes'
                    hash.merge!(parse_user_info(e))
                  else
                    hash[node_name] = [] if hash[node_name].nil?
                    hash[node_name].push(parse_user_info(e))
                  end
                end
              end
            end
          end
        end

        # finds an `<cas:authenticationSuccess>` node in
        # a `<cas:serviceResponse>` body if present; returns nil
        # if the passed body is nil or if there is no such node.
        def find_authentication_success(body)
          return nil if body.nil? || body == ''
          begin
            doc = Nokogiri::XML(body)
            begin
              doc.xpath('/cas:serviceResponse/cas:authenticationSuccess')
            rescue Nokogiri::XML::XPath::SyntaxError
              doc.xpath('/serviceResponse/authenticationSuccess')
            end
          rescue Nokogiri::XML::XPath::SyntaxError
            nil
          end
        end

        # retrieves the `<cas:serviceResponse>` XML from the CAS server
        def get_service_response_body
          result = ''
          http = Net::HTTP.new(@uri.host, @uri.port)
          http.use_ssl = @uri.port == 443 || @uri.instance_of?(URI::HTTPS)
          if http.use_ssl?
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE if @options.disable_ssl_verification?
            http.ca_path = @options.ca_path
          end
          http.start do |c|
            response = c.get "#{@uri.path}?#{@uri.query}", VALIDATION_REQUEST_HEADERS.dup
            result = response.body
          end
          result
        end
      end
    end
  end
end
