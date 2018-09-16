# frozen_string_literal: true

class CustomTemplateFilter
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    CustomTemplate.alphabetic
  end
end
