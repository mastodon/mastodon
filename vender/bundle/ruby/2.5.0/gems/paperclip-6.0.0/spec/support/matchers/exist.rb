RSpec::Matchers.define :exist do |expected|
  match do |actual|
    File.exist?(actual)
  end
end
