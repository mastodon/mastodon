# frozen_string_literal: true

RSpec::Matchers.define :have_private_cache_control do
  match do |page|
    page.response_headers['Cache-Control'] == 'private, no-store'
  end

  failure_message do |page|
    <<~ERROR
      Expected page to have `Cache-Control` header with `private, no-store` but it has:
        #{page.response_headers['Cache-Control']}
    ERROR
  end
end
