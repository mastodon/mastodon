module Assertions
  def assert(truthy, message = nil)
    expect(!!truthy).to(eq(true), message)
  end

  def assert_equal(expected, actual, message = nil)
    expect(actual).to(eq(expected), message)
  end

  def assert_not_equal(expected, actual, message = nil)
    expect(actual).to_not(eq(expected), message)
  end

  def assert_raises(exception_class, message = nil, &block)
    expect(&block).to raise_error(exception_class, message)
  end

  def assert_nothing_raised(&block)
    expect(&block).to_not raise_error
  end

  def assert_nil(thing)
    expect(thing).to be_nil
  end

  def assert_contains(haystack, needle)
    expect(haystack).to include(needle)
  end

  def assert_match(pattern, value)
    expect(value).to match(pattern)
  end

  def assert_no_match(pattern, value)
    expect(value).to_not match(pattern)
  end

  def assert_file_exists(path_to_file)
    expect(path_to_file).to exist
  end

  def assert_file_not_exists(path_to_file)
    expect(path_to_file).to_not exist
  end

  def assert_empty(object)
    expect(object).to be_empty
  end

  def assert_success_response(url)
    url = "http:#{url}" unless url =~ /http/
    Net::HTTP.get_response(URI.parse(url)) do |response|
      assert_equal "200",
        response.code,
        "Expected HTTP response code 200, got #{response.code}"
    end
  end

  def assert_not_found_response(url)
    url = "http:#{url}" unless url =~ /http/
    Net::HTTP.get_response(URI.parse(url)) do |response|
      assert_equal "404", response.code,
        "Expected HTTP response code 404, got #{response.code}"
    end
  end

  def assert_forbidden_response(url)
    url = "http:#{url}" unless url =~ /http/
    Net::HTTP.get_response(URI.parse(url)) do |response|
      assert_equal "403", response.code,
        "Expected HTTP response code 403, got #{response.code}"
    end
  end

  def assert_frame_dimensions(range, frames)
    frames.each_with_index do |frame, frame_index|
      frame.split('x').each_with_index do |dimension, dimension_index |
        assert range.include?(dimension.to_i), "Frame #{frame_index}[#{dimension_index}] should have been within #{range.inspect}, but was #{dimension}"
      end
    end
  end
end
