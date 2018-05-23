class MockInterpolator
  def initialize(options = {})
    @options = options
  end

  def interpolate(pattern, attachment, style_name)
    @interpolated_pattern = pattern
    @interpolated_attachment = attachment
    @interpolated_style_name = style_name
    @options[:result]
  end

  def has_interpolated_pattern?(pattern)
    @interpolated_pattern == pattern
  end

  def has_interpolated_style_name?(style_name)
    @interpolated_style_name == style_name
  end

  def has_interpolated_attachment?(attachment)
    @interpolated_attachment == attachment
  end
end
