# Adapted from
# https://github.com/rails/rails/blob/7f18ea14c8/activejob/lib/active_job/callbacks.rb
require 'active_support/callbacks'

module ActiveModelSerializers
  # = ActiveModelSerializers Callbacks
  #
  # ActiveModelSerializers provides hooks during the life cycle of serialization and
  # allow you to trigger logic. Available callbacks are:
  #
  # * <tt>around_render</tt>
  #
  module Callbacks
    extend ActiveSupport::Concern
    include ActiveSupport::Callbacks

    included do
      define_callbacks :render
    end

    # These methods will be included into any ActiveModelSerializers object, adding
    # callbacks for +render+.
    module ClassMethods
      # Defines a callback that will get called around the render method,
      # whether it is as_json, to_json, or serializable_hash
      #
      #   class ActiveModelSerializers::SerializableResource
      #     include ActiveModelSerializers::Callbacks
      #
      #     around_render do |args, block|
      #       tag_logger do
      #         notify_render do
      #           block.call(args)
      #         end
      #       end
      #     end
      #
      #     def as_json
      #       run_callbacks :render do
      #         adapter.as_json
      #       end
      #     end
      #     # Note: So that we can re-use the instrumenter for as_json, to_json, and
      #     # serializable_hash, we aren't using the usual format, which would be:
      #     # def render(args)
      #     #   adapter.as_json
      #     # end
      #   end
      #
      def around_render(*filters, &blk)
        set_callback(:render, :around, *filters, &blk)
      end
    end
  end
end
