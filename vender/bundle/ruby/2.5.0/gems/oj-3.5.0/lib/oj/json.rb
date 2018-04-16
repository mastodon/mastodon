
require 'ostruct'
require 'oj/state'

module JSON
  NaN = 0.0/0.0 unless defined?(::JSON::NaN)
  Infinity = 1.0/0.0 unless defined?(::JSON::Infinity)
  MinusInfinity = -1.0/0.0 unless defined?(::JSON::MinusInfinity)
  # Taken from the unit test. Note that items like check_circular? are not
  # present.
  PRETTY_STATE_PROTOTYPE = Ext::Generator::State.from_state({
                                              :allow_nan             => false,
                                              :array_nl              => "\n",
                                              :ascii_only            => false,
                                              :buffer_initial_length => 1024,
                                              :depth                 => 0,
                                              :indent                => "  ",
                                              :max_nesting           => 100,
                                              :object_nl             => "\n",
                                              :space                 => " ",
                                              :space_before          => "",
                                            }) unless defined?(::JSON::PRETTY_STATE_PROTOTYPE)
  SAFE_STATE_PROTOTYPE = Ext::Generator::State.from_state({
                                            :allow_nan             => false,
                                            :array_nl              => "",
                                            :ascii_only            => false,
                                            :buffer_initial_length => 1024,
                                            :depth                 => 0,
                                            :indent                => "",
                                            :max_nesting           => 100,
                                            :object_nl             => "",
                                            :space                 => "",
                                            :space_before          => "",
                                            }) unless defined?(::JSON::SAFE_STATE_PROTOTYPE)
  FAST_STATE_PROTOTYPE = Ext::Generator::State.from_state({
                                            :allow_nan             => false,
                                            :array_nl              => "",
                                            :ascii_only            => false,
                                            :buffer_initial_length => 1024,
                                            :depth                 => 0,
                                            :indent                => "",
                                            :max_nesting           => 0,
                                            :object_nl             => "",
                                            :space                 => "",
                                            :space_before          => "",
                                            }) unless defined?(::JSON::FAST_STATE_PROTOTYPE)

  def self.dump_default_options
    Oj::MimicDumpOption.new
  end

  def self.dump_default_options=(h)
    m = Oj::MimicDumpOption.new
    h.each do |k,v|
      m[k] = v
    end
  end

  def self.parser=(p)
    @@parser = p
  end

  def self.parser()
    @@parser
  end

  def self.generator=(g)
    @@generator = g
  end

  def self.generator()
    @@generator
  end

  module Ext
    class Parser
      def initialize(src)
        raise TypeError.new("already initialized") unless @source.nil?
        @source = src
      end

      def source()
        raise TypeError.new("already initialized") if @source.nil?
        @source
      end
      
      def parse()
        raise TypeError.new("already initialized") if @source.nil?
        JSON.parse(@source)
      end
      
    end # Parser
  end # Ext
  
  State = ::JSON::Ext::Generator::State unless defined?(::JSON::State)

  begin
    Object.send(:remove_const, :Parser)
  rescue
  end
  Parser = ::JSON::Ext::Parser unless defined?(::JSON::Parser)
  self.parser = ::JSON::Ext::Parser
  self.generator = ::JSON::Ext::Generator

  # Taken directly from the json gem. Shamelessly copied. It is similar in
  # some ways to the Oj::Bag class or the Oj::EasyHash class.
  class GenericObject < OpenStruct
    class << self
      alias [] new
      
      def json_creatable?
        @json_creatable
      end

      attr_writer :json_creatable

      def json_create(data)
        data = data.dup
        data.delete JSON.create_id
        self[data]
      end

      def from_hash(object)
        case
        when object.respond_to?(:to_hash)
          result = new
          object.to_hash.each do |key, value|
            result[key] = from_hash(value)
          end
          result
        when object.respond_to?(:to_ary)
          object.to_ary.map { |a| from_hash(a) }
        else
          object
        end
      end

      def load(source, proc = nil, opts = {})
        result = ::JSON.load(source, proc, opts.merge(:object_class => self))
        result.nil? ? new : result
      end

      def dump(obj, *args)
        ::JSON.dump(obj, *args)
      end

    end # self

    self.json_creatable = false

    def to_hash
      table
    end

    def [](name)
      __send__(name)
    end unless method_defined?(:[])

    def []=(name, value)
      __send__("#{name}=", value)
    end unless method_defined?(:[]=)

    def |(other)
      self.class[other.to_hash.merge(to_hash)]
    end

    def as_json(*)
      { JSON.create_id => self.class.name }.merge to_hash
    end

    def to_json(*a)
      as_json.to_json(*a)
    end
  end
  
end # JSON
