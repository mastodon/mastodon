RSpec::Matchers.define :have_output do |expected|
  match do |actual|
    actual.output == expected
  end
end

RSpec::Matchers.define :have_error_output do |expected|
  match do |actual|
    actual.error_output == expected
  end
end
