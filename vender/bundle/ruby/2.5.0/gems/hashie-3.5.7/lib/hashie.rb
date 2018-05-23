require 'hashie/logger'
require 'hashie/version'

module Hashie
  autoload :Clash,              'hashie/clash'
  autoload :Dash,               'hashie/dash'
  autoload :Hash,               'hashie/hash'
  autoload :Mash,               'hashie/mash'
  autoload :Trash,              'hashie/trash'
  autoload :Rash,               'hashie/rash'
  autoload :Array,              'hashie/array'
  autoload :Utils,              'hashie/utils'

  module Extensions
    autoload :Coercion,          'hashie/extensions/coercion'
    autoload :DeepMerge,         'hashie/extensions/deep_merge'
    autoload :IgnoreUndeclared,  'hashie/extensions/ignore_undeclared'
    autoload :IndifferentAccess, 'hashie/extensions/indifferent_access'
    autoload :MergeInitializer,  'hashie/extensions/merge_initializer'
    autoload :MethodAccess,      'hashie/extensions/method_access'
    autoload :MethodQuery,       'hashie/extensions/method_access'
    autoload :MethodReader,      'hashie/extensions/method_access'
    autoload :MethodWriter,      'hashie/extensions/method_access'
    autoload :StringifyKeys,     'hashie/extensions/stringify_keys'
    autoload :SymbolizeKeys,     'hashie/extensions/symbolize_keys'
    autoload :DeepFetch,         'hashie/extensions/deep_fetch'
    autoload :DeepFind,          'hashie/extensions/deep_find'
    autoload :DeepLocate,        'hashie/extensions/deep_locate'
    autoload :PrettyInspect,     'hashie/extensions/pretty_inspect'
    autoload :KeyConversion,     'hashie/extensions/key_conversion'
    autoload :MethodAccessWithOverride, 'hashie/extensions/method_access'
    autoload :StrictKeyAccess,   'hashie/extensions/strict_key_access'
    autoload :RubyVersion,       'hashie/extensions/ruby_version'
    autoload :RubyVersionCheck,  'hashie/extensions/ruby_version_check'

    module Parsers
      autoload :YamlErbParser, 'hashie/extensions/parsers/yaml_erb_parser'
    end

    module Dash
      autoload :IndifferentAccess, 'hashie/extensions/dash/indifferent_access'
      autoload :PropertyTranslation, 'hashie/extensions/dash/property_translation'
      autoload :Coercion, 'hashie/extensions/dash/coercion'
    end

    module Mash
      autoload :KeepOriginalKeys, 'hashie/extensions/mash/keep_original_keys'
      autoload :SafeAssignment, 'hashie/extensions/mash/safe_assignment'
      autoload :SymbolizeKeys, 'hashie/extensions/mash/symbolize_keys'
    end

    module Array
      autoload :PrettyInspect, 'hashie/extensions/array/pretty_inspect'
    end
  end

  class << self
    include Hashie::Extensions::StringifyKeys::ClassMethods
    include Hashie::Extensions::SymbolizeKeys::ClassMethods
  end

  require 'hashie/railtie' if defined?(::Rails)
end
