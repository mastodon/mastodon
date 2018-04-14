module Aws
  module S3
    module Plugins

      # When making calls to {S3::Client#create_bucket} outside the
      # "classic" region, the bucket location constraint must be specified.
      # This plugin auto populates the constraint to the configured region.
      class LocationConstraint < Seahorse::Client::Plugin

        class Handler < Seahorse::Client::Handler

          def call(context)
            unless context.config.region == 'us-east-1'
              populate_location_constraint(context.params, context.config.region)
            end
            @handler.call(context)
          end

          private

          def populate_location_constraint(params, region)
            params[:create_bucket_configuration] ||= {}
            params[:create_bucket_configuration][:location_constraint] ||= region
          end

        end

        handler(Handler, step: :initialize, operations: [:create_bucket])

      end
    end
  end
end
