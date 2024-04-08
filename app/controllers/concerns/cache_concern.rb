# frozen_string_literal: true

module CacheConcern
  extend ActiveSupport::Concern

  class_methods do
    def vary_by(value, **kwargs)
      before_action(**kwargs) do |controller|
        response.headers['Vary'] = value.respond_to?(:call) ? controller.instance_exec(&value) : value
      end
    end
  end

  included do
    after_action :enforce_cache_control!
  end

  # Prevents high-entropy headers such as `Cookie`, `Signature` or `Authorization`
  # from being used as cache keys, while allowing to `Vary` on them (to not serve
  # anonymous cached data to authenticated requests when authentication matters)
  def enforce_cache_control!
    vary = response.headers['Vary']&.split&.map { |x| x.strip.downcase }
    return unless vary.present? && %w(cookie authorization signature).any? { |header| vary.include?(header) && request.headers[header].present? }

    response.cache_control.replace(private: true, no_store: true)
  end

  def render_with_cache(**options)
    raise ArgumentError, 'Only JSON render calls are supported' unless options.key?(:json) || block_given?

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
