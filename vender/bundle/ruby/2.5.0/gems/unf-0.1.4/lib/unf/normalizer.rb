require 'singleton'
if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
  require 'unf/normalizer_jruby'
else
  require 'unf/normalizer_cruby'
end

# UTF-8 string normalizer class.  Implementations may vary depending
# on the platform.
class UNF::Normalizer
  include Singleton

  class << self
    # :singleton-method: instance
    #
    # Returns a singleton normalizer instance.

    # :singleton-method: new
    #
    # Returns a new normalizer instance.  Use +singleton+ instead.
    public :new

    # A shortcut for instance.normalize(string, form).
    def normalize(string, form)
      instance.normalize(string, form)
    end
  end

  # :method: normalize
  # :call-seq:
  #   normalize(string, form)
  #
  # Normalizes a UTF-8 string into a given form (:nfc, :nfd, :nfkc or
  # :nfkd).
end
