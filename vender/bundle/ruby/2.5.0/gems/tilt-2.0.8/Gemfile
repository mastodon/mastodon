source 'https://rubygems.org'

gemspec

gem 'rake'
gem 'minitest', '~> 5.0'

group :development do
  gem 'yard', '~> 0.9.0'
  gem 'ronn', '~> 0.7.3'
end

can_execjs = (RUBY_VERSION >= '1.9.3')

group :primary do
  gem 'builder'
  gem 'haml', '>= 4' if RUBY_VERSION >= '2.0.0'
  gem 'erubis'
  gem 'markaby'
  gem 'sass'

  if can_execjs
    gem 'less'
    gem 'coffee-script'
    gem 'livescript'
    gem 'babel-transpiler'
    gem 'typescript-node'
  end
end

platform :mri do
  gem 'duktape', '~> 1.3.0.6' if can_execjs
end

group :secondary do
  gem 'creole'
  gem 'kramdown'
  gem 'rdoc'
  gem 'radius'
  gem 'asciidoctor', '>= 0.1.0'
  gem 'liquid'
  gem 'maruku'
  gem 'pandoc-ruby'

  if RUBY_VERSION > '1.9.3'
    gem 'prawn', '>= 2.0.0'
    gem 'pdf-reader', '~> 1.3.3'
  end

  gem 'nokogiri' if RUBY_VERSION > '1.9.2'

  platform :ruby do
    gem 'wikicloth'
    gem 'yajl-ruby'
    gem 'redcarpet' if RUBY_VERSION > '1.8.7'
    gem 'rdiscount', '>= 2.1.6' if RUBY_VERSION != '1.9.2'
    gem 'RedCloth'
    gem 'commonmarker' if RUBY_VERSION > '1.9.3'
  end

  platform :mri do
    gem 'bluecloth'
  end
end

