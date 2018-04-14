source "https://rubygems.org"
gemspec

# if ::File.directory?(gem_path = "../redis-store")
#   gem "redis-store", [">= 1.2.0", "< 1.4"], path: gem_path
# end

# if ::File.directory?(gem_path = "../redis-rack")
#   gem "redis-rack", "~> 2.0.0.pre", path: gem_path
# end

# if ::File.directory?(gem_path = "../redis-activesupport")
#   gem "redis-activesupport", '>= 4.0.0', '< 5.1', path: gem_path
# end

# if ::File.directory?(gem_path = "../redis-actionpack")
#   gem "redis-actionpack", ">= 4.0.0", '< 5.1', path: gem_path
# end

version = ENV["RAILS_VERSION"] || '5'

rails = case version
when "master"
  {:github => "rails/rails"}
else
  "~> #{version}.0"
end

gem "rails", rails
