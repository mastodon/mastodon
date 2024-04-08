# frozen_string_literal: true

module CacheConcern
  extend ActiveSupport::Concern

  def render_with_cache(**options)
    raise ArgumentError, 'only JSON render calls are supported' unless options.key?(:json) || block_given?

    key        = options.delete(:key) || [[params[:controller], params[:action]].join('/'), options[:json].respond_to?(:cache_key) ? options[:json].cache_key : nil, options[:fields].nil? ? nil : options[:fields].join(',')].compact.join(':')
    expires_in = options.delete(:expires_in) || 3.minutes
    body       = Rails.cache.read(key, raw: true)

    if body
      render(options.except(:json, :serializer, :each_serializer, :adapter, :fields).merge(json: body))
    else
      if block_given?
        options[:json] = yield
      elsif options[:json].is_a?(Symbol)
        options[:json] = send(options[:json])
      end

      render(options)
      Rails.cache.write(key, response.body, expires_in: expires_in, raw: true)
    end
  end

  def set_cache_headers
    response.headers['Vary'] = public_fetch_mode? ? 'Accept' : 'Accept, Signature'
  end

  # TODO: Rename this method, as it does not perform any caching anymore.
  def cache_collection(raw, klass)
    return raw unless klass.respond_to?(:preload_cacheable_associations)

    records = raw.to_a

    klass.preload_cacheable_associations(records)

    records
  end

  # TODO: Rename this method, as it does not perform any caching anymore.
  def cache_collection_paginated_by_id(raw, klass, limit, options)
    cache_collection raw.to_a_paginated_by_id(limit, options), klass
  end
end
