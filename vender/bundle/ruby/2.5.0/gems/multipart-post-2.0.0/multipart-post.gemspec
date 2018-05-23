# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "multipart_post"

Gem::Specification.new do |s|
  s.name        = "multipart-post"
  s.version     = MultipartPost::VERSION
  s.authors     = ["Nick Sieger"]
  s.email       = ["nick@nicksieger.com"]
  s.homepage    = "https://github.com/nicksieger/multipart-post"
  s.summary     = %q{A multipart form post accessory for Net::HTTP.}
  s.license     = "MIT"
  s.description = %q{Use with Net::HTTP to do multipart form posts.  IO values that have #content_type, #original_filename, and #local_path will be posted as a binary file.}

  s.rubyforge_project = "caldersphere"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.rdoc_options = ["--main", "README.md", "-SHN", "-f", "darkfish"]
  s.require_paths = ["lib"]
end
