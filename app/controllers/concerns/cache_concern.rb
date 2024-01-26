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

  def cache_collection(raw, klass)
    return raw unless klass.respond_to?(:with_includes)

    raw = raw.cache_ids.to_a if raw.is_a?(ActiveRecord::Relation)
    return [] if raw.empty?

    cached_keys_with_value = Rails.cache.read_multi(*raw).transform_keys(&:id)

    uncached_ids = raw.map(&:id) - cached_keys_with_value.keys

    klass.reload_stale_associations!(cached_keys_with_value.values) if klass.respond_to?(:reload_stale_associations!)

    unless uncached_ids.empty?
      uncached = klass.where(id: uncached_ids).with_includes.index_by(&:id)
      Rails.cache.write_multi(uncached.values.to_h { |i| [i, i] })
    end

    raw.filter_map { |item| cached_keys_with_value[item.id] || uncached[item.id] }
  end

  def cache_collection_paginated_by_id(raw, klass, limit, options)
    cache_collection raw.cache_ids.to_a_paginated_by_id(limit, options), klass
  end
end
