module Aws
  module S3
    module Plugins
      class GetBucketLocationFix < Seahorse::Client::Plugin

        class Handler < Seahorse::Client::Handler

          def call(context)
            @handler.call(context).on(200) do |response|
              response.data = S3::Types::GetBucketLocationOutput.new
              xml = context.http_response.body_contents
              matches = xml.match(/>(.+?)<\/LocationConstraint>/)
              response.data[:location_constraint] = matches ? matches[1] : ''
            end
          end
        end

        handler(Handler, priority: 60, operations: [:get_bucket_location])

      end
    end
  end
end
