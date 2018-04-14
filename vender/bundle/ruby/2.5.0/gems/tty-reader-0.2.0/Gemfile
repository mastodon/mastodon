source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gemspec

group :test do
  gem 'benchmark-ips', '~> 2.7.2'
  gem 'simplecov', '~> 0.14.1'
  gem 'coveralls', '~> 0.8.21'
end

group :tools do
  gem 'byebug', platform: :mri
end

group :metrics do
  gem 'yard',      '~> 0.9.12'
  gem 'yardstick', '~> 0.9.9'
end
