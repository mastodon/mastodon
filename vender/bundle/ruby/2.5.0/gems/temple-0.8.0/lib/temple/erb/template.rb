module Temple
  # ERB example implementation
  #
  # Example usage:
  #   Temple::ERB::Template.new { "<%= 'Hello, world!' %>" }.render
  #
  module ERB
    # ERB Template class
    Template = Temple::Templates::Tilt(Engine)
  end
end
