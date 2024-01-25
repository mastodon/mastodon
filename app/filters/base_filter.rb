# frozen_string_literal: true

class BaseFilter
  attr_reader :params

  def initialize(params)
    @params = params.to_h.symbolize_keys
  end

  def results
    default_filter_scope.tap do |scope|
      relevant_params.each do |key, value|
        scope.merge!(scope_for(key, value)) if value.present?
      end
    end
  end

  private

  def relevant_params
    params.except(ignored_params)
  end

  def ignored_params
    %i(page)
  end

  def default_filter_scope
    raise 'Override in subclass with starting scope'
  end

  def scope_for(key, value)
    raise "Override in subclass using #{key} and #{value} to build a scope"
  end
end
