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
    @limit   = -1
    @skip    = 0
  end

  def allowed
    @allowed = true
    self
  end

  def in_locale(value)
    @locale = value
    self
  end

  def skip(value)
    @skip = value
    self
  end

  def limit(value)
    @limit = value
    self
  end

  def records
    load
    @records
  end

  delegate :each, :empty?, :first, :last, to: :records

  def to_ary
    records.dup
  end

  alias to_a to_ary

  def to_arel
    tmp_ids = ids

    if tmp_ids.empty?
      klass.none
    else
      klass.joins("join unnest(array[#{tmp_ids.join(',')}]) with ordinality as x (id, ordering) on #{klass.table_name}.id = x.id").reorder('x.ordering')
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

  def ids
    redis.zrevrange(key, @skip, @limit.positive? ? @limit - 1 : @limit).map(&:to_i)
  end

  def perform_queries
    apply_scopes(to_arel).to_a
  end

  def apply_scopes(scope)
    scope
  end
end
