require 'thread'

module Aws

  # This module provides the ability to specify the data and/or errors to
  # return when a client is using stubbed responses. Pass
  # `:stub_responses => true` to a client constructor to enable this
  # behavior.
  module ClientStubs

    # @api private
    def setup_stubbing
      @stubs = {}
      @stub_mutex = Mutex.new
      if Hash === @config.stub_responses
        @config.stub_responses.each do |operation_name, stubs|
          apply_stubs(operation_name, Array === stubs ? stubs : [stubs])
        end
      end
    end

    # Configures what data / errors should be returned from the named operation
    # when response stubbing is enabled.
    #
    # ## Basic usage
    #
    # When you enable response stubbing, the client will generate fake
    # responses and will not make any HTTP requests.
    #
    #     client = Aws::S3::Client.new(stub_responses: true)
    #     client.list_buckets
    #     #=> #<struct Aws::S3::Types::ListBucketsOutput buckets=[], owner=nil>
    #
    # You can provide stub data that will be returned by the client.
    #
    #     # stub data in the constructor
    #     client = Aws::S3::Client.new(stub_responses: {
    #       list_buckets: { buckets: [{name: 'my-bucket' }] },
    #       get_object: { body: 'data' },
    #     })
    #
    #     client.list_buckets.buckets.map(&:name) #=> ['my-bucket']
    #     client.get_object(bucket:'name', key:'key').body.read #=> 'data'
    #
    # You can also specify the stub data using {#stub_responses}
    #
    #     client = Aws::S3::Client.new(stub_responses: true)
    #     client.stub_responses(:list_buckets, {
    #       buckets: [{ name: 'my-bucket' }]
    #     })
    #
    #     client.list_buckets.buckets.map(&:name)
    #     #=> ['my-bucket']
    #
    # With a Resource class {#stub_responses} on the corresponding client:
    #
    #     s3 = Aws::S3::Resource.new(stub_responses: true)
    #     s3.client.stub_responses(:list_buckets, {
    #       buckets: [{ name: 'my-bucket' }]
    #     })
    #
    #     s3.buckets.map(&:name)
    #     #=> ['my-bucket']
    #
    # Lastly, default stubs can be configured via `Aws.config`:
    #
    #     Aws.config[:s3] = {
    #       stub_responses: {
    #         list_buckets: { buckets: [{name: 'my-bucket' }] }
    #       }
    #     }
    #
    #     Aws::S3::Client.new.list_buckets.buckets.map(&:name)
    #     #=> ['my-bucket']
    #
    #     Aws::S3::Resource.new.buckets.map(&:name)
    #     #=> ['my-bucket']
    #
    # ## Dynamic Stubbing
    #
    # In addition to creating static stubs, it's also possible to generate
    # stubs dynamically based on the parameters with which operations were
    # called, by passing a `Proc` object:
    #
    #     s3 = Aws::S3::Resource.new(stub_responses: true)
    #     s3.client.stub_responses(:put_object, -> (context) {
    #       s3.client.stub_responses(:get_object, content_type: context.params[:content_type])
    #     })
    #
    # The yielded object is an instance of {Seahorse::Client::RequestContext}.
    #
    # ## Stubbing Errors
    #
    # When stubbing is enabled, the SDK will default to generate
    # fake responses with placeholder values. You can override the data
    # returned. You can also specify errors it should raise.
    #
    #     # simulate service errors, give the error code
    #     client.stub_responses(:get_object, 'NotFound')
    #     client.get_object(bucket:'aws-sdk', key:'foo')
    #     #=> raises Aws::S3::Errors::NotFound
    #
    #     # to simulate other errors, give the error class, you must
    #     # be able to construct an instance with `.new`
    #     client.stub_responses(:get_object, Timeout::Error)
    #     client.get_object(bucket:'aws-sdk', key:'foo')
    #     #=> raises new Timeout::Error
    #
    #     # or you can give an instance of an error class
    #     client.stub_responses(:get_object, RuntimeError.new('custom message'))
    #     client.get_object(bucket:'aws-sdk', key:'foo')
    #     #=> raises the given runtime error object
    #
    # ## Stubbing HTTP Responses
    #
    # As an alternative to providing the response data, you can provide
    # an HTTP response.
    #
    #     client.stub_responses(:get_object, {
    #       status_code: 200,
    #       headers: { 'header-name' => 'header-value' },
    #       body: "...",
    #     })
    #
    # To stub a HTTP response, pass a Hash with all three of the following
    # keys set:
    #
    # * **`:status_code`** - <Integer> - The HTTP status code
    # * **`:headers`** - Hash<String,String> - A hash of HTTP header keys and values
    # * **`:body`** - <String,IO> - The HTTP response body.
    #
    # ## Stubbing Multiple Responses
    #
    # Calling an operation multiple times will return similar responses.
    # You can configure multiple stubs and they will be returned in sequence.
    #
    #     client.stub_responses(:head_object, [
    #       'NotFound',
    #       { content_length: 150 },
    #     ])
    #
    #     client.head_object(bucket:'aws-sdk', key:'foo')
    #     #=> raises Aws::S3::Errors::NotFound
    #
    #     resp = client.head_object(bucket:'aws-sdk', key:'foo')
    #     resp.content_length #=> 150
    #
    # @param [Symbol] operation_name
    #
    # @param [Mixed] stubs One or more responses to return from the named
    #   operation.
    #
    # @return [void]
    #
    # @raise [RuntimeError] Raises a runtime error when called
    #   on a client that has not enabled response stubbing via
    #   `:stub_responses => true`.
    #
    def stub_responses(operation_name, *stubs)
      if config.stub_responses
        apply_stubs(operation_name, stubs.flatten)
      else
        msg = 'stubbing is not enabled; enable stubbing in the constructor '
        msg << 'with `:stub_responses => true`'
        raise msg
      end
    end

    # Generates and returns stubbed response data from the named operation.
    #
    #     s3 = Aws::S3::Client.new
    #     s3.stub_data(:list_buckets)
    #     #=> #<struct Aws::S3::Types::ListBucketsOutput buckets=[], owner=#<struct Aws::S3::Types::Owner display_name="DisplayName", id="ID">>
    #
    # In addition to generating default stubs, you can provide data to
    # apply to the response stub.
    #
    #     s3.stub_data(:list_buckets, buckets:[{name:'aws-sdk'}])
    #     #=> #<struct Aws::S3::Types::ListBucketsOutput
    #       buckets=[#<struct Aws::S3::Types::Bucket name="aws-sdk", creation_date=nil>],
    #       owner=#<struct Aws::S3::Types::Owner display_name="DisplayName", id="ID">>
    #
    # @param [Symbol] operation_name
    # @param [Hash] data
    # @return [Structure] Returns a stubbed response data structure. The
    #   actual class returned will depend on the given `operation_name`.
    def stub_data(operation_name, data = {})
      Stubbing::StubData.new(config.api.operation(operation_name)).stub(data)
    end

    # @api private
    def next_stub(context)
      operation_name = context.operation_name.to_sym
      stub = @stub_mutex.synchronize do
        stubs = @stubs[operation_name] || []
        case stubs.length
        when 0 then default_stub(operation_name)
        when 1 then stubs.first
        else stubs.shift
        end
      end
      Proc === stub ? convert_stub(operation_name, stub.call(context)) : stub
    end

    private

    def default_stub(operation_name)
      stub = stub_data(operation_name)
      http_response_stub(operation_name, stub)
    end

    # This method converts the given stub data and converts it to a
    # HTTP response (when possible). This enables the response stubbing
    # plugin to provide a HTTP response that triggers all normal events
    # during response handling.
    def apply_stubs(operation_name, stubs)
      @stub_mutex.synchronize do
        @stubs[operation_name.to_sym] = stubs.map do |stub|
          convert_stub(operation_name, stub)
        end
      end
    end

    def convert_stub(operation_name, stub)
      case stub
      when Proc then stub
      when Exception, Class then { error: stub }
      when String then service_error_stub(stub)
      when Hash then http_response_stub(operation_name, stub)
      else { data: stub }
      end
    end

    def service_error_stub(error_code)
      { http: protocol_helper.stub_error(error_code) }
    end

    def http_response_stub(operation_name, data)
      if Hash === data && data.keys.sort == [:body, :headers, :status_code]
        { http: hash_to_http_resp(data) }
      else
        { http: data_to_http_resp(operation_name, data) }
      end
    end

    def hash_to_http_resp(data)
      http_resp = Seahorse::Client::Http::Response.new
      http_resp.status_code = data[:status_code]
      http_resp.headers.update(data[:headers])
      http_resp.body = data[:body]
      http_resp
    end

    def data_to_http_resp(operation_name, data)
      api = config.api
      operation = api.operation(operation_name)
      ParamValidator.validate!(operation.output, data)
      protocol_helper.stub_data(api, operation, data)
    end

    def protocol_helper
      case config.api.metadata['protocol']
      when 'json'        then Stubbing::Protocols::Json
      when 'query'       then Stubbing::Protocols::Query
      when 'ec2'         then Stubbing::Protocols::EC2
      when 'rest-json'   then Stubbing::Protocols::RestJson
      when 'rest-xml'    then Stubbing::Protocols::RestXml
      when 'api-gateway' then Stubbing::Protocols::ApiGateway
      else raise "unsupported protocol"
      end.new
    end
  end
end
