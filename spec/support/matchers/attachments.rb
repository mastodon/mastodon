# frozen_string_literal: true

RSpec::Matchers.define :have_attachment do |value|
  match do |response|
    expect(response.headers['Content-Disposition'])
      .to match(<<~FILENAME.squish)
        attachment; filename="#{value}"
      FILENAME
  end

  failure_message do |response|
    <<~ERROR
      Expected response to have file attachment of `#{value}` but was:
      Content-Disposition: #{response.headers['Content-Disposition']}
    ERROR
  end
end
