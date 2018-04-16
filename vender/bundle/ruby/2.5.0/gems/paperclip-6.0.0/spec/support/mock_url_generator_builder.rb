class MockUrlGeneratorBuilder
  def initializer
  end

  def new(attachment)
    @attachment = attachment
    @attachment_options = @attachment.options
    self
  end

  def for(style_name, options)
    @generated_url_with_style_name = style_name
    @generated_url_with_options = options
    "hello"
  end

  def has_generated_url_with_options?(options)
    # options.is_a_subhash_of(@generated_url_with_options)
    options.inject(true) do |acc,(k,v)|
      acc && @generated_url_with_options[k] == v
    end
  end

  def has_generated_url_with_style_name?(style_name)
    @generated_url_with_style_name == style_name
  end
end
