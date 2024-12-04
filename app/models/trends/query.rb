# frozen_string_literal: true

class Trends::Query
  include Enumerable

  attr_reader :klass, :loaded

  alias loaded? loaded

  def initialize(_prefix, klass)
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
    raise NotImplementedError
  end

  private

  def load
    unless loaded?
      @records = perform_queries
      @loaded  = true
    end

    self
  end

  def perform_queries
    to_arel.to_a
  end
end
