# frozen_string_literal: true

module SearchStoplight
  def elastic_stoplight_wrapper
    Stoplight.light('search:elasticsearch')
  end
end
