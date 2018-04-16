module Responders
  # Set HTTP Last-Modified headers based on the given resource. It's used only
  # on API behavior (to_format) and is useful for a client to check in the server
  # if a resource changed after a specific date or not.
  #
  # This is not usually not used in html requests because pages contains a lot
  # information besides the resource information, as current_user, flash messages,
  # widgets... that are better handled with other strategies, as fragment caches and
  # the digest of the body.
  #
  module HttpCacheResponder
    def initialize(controller, resources, options={})
      super
      @http_cache = options.delete(:http_cache)
    end

    def to_format
      return if do_http_cache? && do_http_cache!
      super
    end

  protected

    def do_http_cache!
      timestamp = resources.map do |resource|
        resource.updated_at.try(:utc) if resource.respond_to?(:updated_at)
      end.compact.max

      controller.response.last_modified ||= timestamp if timestamp

      head :not_modified if fresh = request.fresh?(controller.response)
      fresh
    end

    def do_http_cache?
      get? && @http_cache != false && ActionController::Base.perform_caching &&
        persisted? && resource.respond_to?(:updated_at)
    end

    def persisted?
      resource.respond_to?(:persisted?) ? resource.persisted? : true
    end
  end
end
