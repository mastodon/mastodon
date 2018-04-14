require 'memfs'

RSpec.configure do |config|
  config.around(memfs: true) do |example|
    MemFs.activate { example.run }
  end
end
