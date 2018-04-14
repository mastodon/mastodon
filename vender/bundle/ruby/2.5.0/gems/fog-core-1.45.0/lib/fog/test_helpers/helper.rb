require "excon"

ENV["FOG_RC"]         = ENV["FOG_RC"] || File.expand_path("../.fog", __FILE__)
ENV["FOG_CREDENTIAL"] = ENV["FOG_CREDENTIAL"] || "default"

Excon.defaults.merge!(:debug_request => true, :debug_response => true)

LOREM = <<HERE
Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis
nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore
eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident,
sunt in culpa qui officia deserunt mollit anim id est laborum.
HERE

require "tempfile"

def lorem_file
  Tempfile.new("lorem").tap do |f|
    f.write(LOREM)
    f.rewind
  end
end

def array_differences(array_a, array_b)
  (array_a - array_b) | (array_b - array_a)
end

__END__
