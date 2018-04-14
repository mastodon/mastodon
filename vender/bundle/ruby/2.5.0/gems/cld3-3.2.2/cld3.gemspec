# Copyright 2017 Akihiko Odaki <akihiko.odaki.4i@stu.hosei.ac.jp>
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#==============================================================================

Gem::Specification.new do |gem|
  gem.name = "cld3"
  gem.version = "3.2.2"
  gem.summary = "Compact Language Detector v3 (CLD3)"
  gem.description = "Compact Language Detector v3 (CLD3) is a neural network model for language identification."
  gem.license = "Apache-2.0"
  gem.homepage = "https://github.com/akihikodaki/cld3-ruby"
  gem.author = "Akihiko Odaki"
  gem.email = "akihiko.odaki.4i@stu.hosei.ac.jp"
  gem.required_ruby_version = [ ">= 2.3.0", "< 2.6.0" ]
  gem.add_dependency "ffi", [ ">= 1.1.0", "< 1.10.0" ]
  gem.add_development_dependency "rspec", [ ">=3.0.0", "< 3.8.0" ]
  gem.files = Dir[
    "Gemfile", "LICENSE", "LICENSE_CLD3", "README.md",
    "cld3.gemspec", "ext/**/*", "lib/**/*"
  ]
  gem.require_paths = [ "lib" ]
  gem.extensions = [ "ext/cld3/extconf.rb" ]
end
