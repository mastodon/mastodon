# frozen_string_literal: true

class Trends::Query
  include Redisable
  include Enumerable

  attr_reader :prefix, :klass, :loaded

  alias loaded? loaded

  def initialize(prefix, klass)
    @prefix  = prefix
    @klass   = klass
    @records = []
    @loaded  = false
    @allowed = false
    @limit   = nil
    @offset  = nil
  end

  def allowed!
    @allowed = true
    self
  end

  def allowed
    clone.allowed!
  end

  def in_locale!(value)
    @locale = value
    self
  end

  def in_locale(value)
    clone.in_locale!(value)
  end

  def offset!(value)
    @offset = value.to_i
    self
  end

  def offset(value)
    clone.offset!(value)
  end

  def limit!(value)
    @limit = value.to_i
    self
  end

  def limit(value)
    clone.limit!(value)
  end

  def records
    load
    @records
  end

  delegate :each, :empty?, :first, :last, :size, to: :records

  def to_ary
    records.dup
  end

  alias to_a to_ary

  def to_arel
    if ids_for_key.empty?
      klass.none
    else
      scope = klass.joins(sanitized_join_sql).reorder('x.ordering')
      scope = scope.offset(@offset) if @offset.present?
      scope = scope.limit(@limit) if @limit.present?
      scope
    end
  end

  private

  def key
    [@prefix, @allowed ? 'allowed' : 'all', @locale].compact.join(':')
  end

  def load
    unless loaded?
      @records = perform_queries
      @loaded  = true
    end

    self
  end

  def ids_for_key
    @ids_for_key ||= redis.zrevrange(key, 0, -1).map(&:to_i)
  end

  def sanitized_join_sql
    ActiveRecord::Base.sanitize_sql_array(join_sql_array)
  end

  def join_sql_array
    [join_sql_query, ids_for_key]
  end

  def join_sql_query
    <<~SQL.squish
      JOIN unnest(array[?]) WITH ordinality AS x (id, ordering) ON #{klass.table_name}.id = x.id
    SQL
  end

  def perform_queries
    apply_scopes(to_arel).to_a
  end

  def apply_scopes(scope)
    scope
  end
end
