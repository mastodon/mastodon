require 'set'

module Sprockets
  # Internal: The first processor in the pipeline that reads the file into
  # memory and passes it along as `input[:data]`.  
  class FileReader
    def self.call(input)
      env = input[:environment]
      data = env.read_file(input[:filename], input[:content_type])
      dependencies = Set.new(input[:metadata][:dependencies])
      dependencies += [env.build_file_digest_uri(input[:filename])]
      { data: data, dependencies: dependencies }
    end
  end
end
