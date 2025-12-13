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
    @account = nil
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

  def filtered_for!(account)
    @account = account
    self
  end

  def filtered_for(account)
    clone.filtered_for!(account)
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

  def language_order_clause
    Arel::Nodes::Case.new.when(language_is_preferred).then(1).else(0).desc
  end

  def language_is_preferred
    trend_class
      .arel_table[:language]
      .in(preferred_languages)
  end

  def preferred_languages
    if @account&.chosen_languages.present?
      @account.chosen_languages
    else
      @locale
    end
  end
end
