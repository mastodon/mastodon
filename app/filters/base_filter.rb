# frozen_string_literal: true

class BaseFilter
  attr_reader :params

  def initialize(params)
    @params = params
  end
end
