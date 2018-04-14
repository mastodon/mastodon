module RubyVersionCheck
  def with_minimum_ruby(version)
    yield if Hashie::Extensions::RubyVersion.new(RUBY_VERSION) >=
             Hashie::Extensions::RubyVersion.new(version)
  end
end
