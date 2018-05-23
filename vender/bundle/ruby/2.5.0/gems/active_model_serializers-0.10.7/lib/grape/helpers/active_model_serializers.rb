# Helpers can be included in your Grape endpoint as: helpers Grape::Helpers::ActiveModelSerializers

module Grape
  module Helpers
    module ActiveModelSerializers
      # A convenience method for passing ActiveModelSerializers serializer options
      #
      # Example: To include relationships in the response: render(post, include: ['comments'])
      #
      # Example: To include pagination meta data: render(posts, meta: { page: posts.page, total_pages: posts.total_pages })
      def render(resource, active_model_serializer_options = {})
        env[:active_model_serializer_options] = active_model_serializer_options
        resource
      end
    end
  end
end
