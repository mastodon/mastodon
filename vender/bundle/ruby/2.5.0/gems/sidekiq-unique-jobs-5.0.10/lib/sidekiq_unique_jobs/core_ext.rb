# frozen_string_literal: true

begin
  require 'active_support/core_ext/hash/keys'
  require 'active_support/core_ext/hash/deep_merge'
rescue LoadError
  class Hash
    unless {}.respond_to?(:slice)
      def slice(*keys)
        keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
        keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if key?(k) }
      end
    end

    unless {}.respond_to?(:stringify_keys)
      def stringify_keys
        transform_keys(&:to_s)
      end
    end

    unless {}.respond_to?(:transform_keys)
      def transform_keys
        result = {}
        each_key do |key|
          result[yield(key)] = self[key]
        end
        result
      end
    end

    unless {}.respond_to?(:slice!)
      def slice!(*keys)
        keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
        omit = slice(*self.keys - keys)
        hash = slice(*keys)
        hash.default      = default
        hash.default_proc = default_proc if default_proc
        replace(hash)
        omit
      end
    end
  end
end

class Array
  unless [].respond_to?(:extract_options!)
    def extract_options!
      if last.is_a?(Hash) && last.instance_of?(Hash)
        pop
      else
        {}
      end
    end
  end
end

class String
  unless ''.respond_to?(:classify)
    def classify
      camelize(sub(/.*\./, ''))
    end
  end

  unless ''.respond_to?(:camelize)
    def camelize(uppercase_first_letter = true)
      string = self
      string = if uppercase_first_letter
                 string.sub(/^[a-z\d]*/) { $&.capitalize }
               else
                 string.sub(/^(?:(?=\b|[A-Z_])|\w)/) { $&.downcase }
               end
      string.gsub!(%r{(?:_|(\/))([a-z\d]*)}i) do
        "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}"
      end
      string.gsub!(%r{/}, '::')
      string
    end
  end
end
