class   ProgressBar
module  Calculators
class   RunningAverage
  def self.calculate(current_average, new_value_to_average, smoothing_factor)
    new_value_to_average * (1.0 - smoothing_factor) + current_average * smoothing_factor
  end
end
end
end
