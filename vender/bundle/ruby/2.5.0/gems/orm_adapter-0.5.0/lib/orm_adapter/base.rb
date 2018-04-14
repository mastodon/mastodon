module OrmAdapter
  class Base
    attr_reader :klass

    # Your ORM adapter needs to inherit from this Base class and its adapter
    # will be registered. To create an adapter you should create an inner
    # constant "OrmAdapter" e.g. ActiveRecord::Base::OrmAdapter
    #
    # @see orm_adapters/active_record
    # @see orm_adapters/datamapper
    # @see orm_adapters/mongoid
    def self.inherited(adapter)
      OrmAdapter.adapters << adapter
      super
    end

    def initialize(klass)
      @klass = klass
    end

    # Get a list of column/property/field names
    def column_names
      raise NotSupportedError
    end

    # Get an instance by id of the model. Raises an error if a model is not found.
    # This should comply with ActiveModel#to_key API, i.e.:
    #
    #   User.to_adapter.get!(@user.to_key) == @user
    #
    def get!(id)
      raise NotSupportedError
    end

    # Get an instance by id of the model. Returns nil if a model is not found.
    # This should comply with ActiveModel#to_key API, i.e.:
    #
    #   User.to_adapter.get(@user.to_key) == @user
    #
    def get(id)
      raise NotSupportedError
    end

    # Find the first instance, optionally matching conditions, and specifying order
    #
    # You can call with just conditions, providing a hash
    #
    #   User.to_adapter.find_first :name => "Fred", :age => 23
    #
    # Or you can specify :order, and :conditions as keys
    #
    #   User.to_adapter.find_first :conditions => {:name => "Fred", :age => 23}
    #   User.to_adapter.find_first :order => [:age, :desc]
    #   User.to_adapter.find_first :order => :name, :conditions => {:age => 18}
    #
    # When specifying :order, it may be
    # * a single arg e.g. <tt>:order => :name</tt>
    # * a single pair with :asc, or :desc as last, e.g. <tt>:order => [:name, :desc]</tt>
    # * an array of single args or pairs (with :asc or :desc as last), e.g. <tt>:order => [[:name, :asc], [:age, :desc]]</tt>
    #
    def find_first(options = {})
      raise NotSupportedError
    end

    # Find all models, optionally matching conditions, and specifying order
    # @see OrmAdapter::Base#find_first for how to specify order and conditions
    def find_all(options = {})
      raise NotSupportedError
    end

    # Create a model using attributes
    def create!(attributes = {})
      raise NotSupportedError
    end

    # Destroy an instance by passing in the instance itself.
    def destroy(object)
      raise NotSupportedError
    end

    protected

    def valid_object?(object)
      object.class == klass
    end

    def wrap_key(key)
      key.is_a?(Array) ? key.first : key
    end

    # given an options hash,
    # with optional :conditions, :order, :limit and :offset keys,
    # returns conditions, normalized order, limit and offset
    def extract_conditions!(options = {})
      order      = normalize_order(options.delete(:order))
      limit      = options.delete(:limit)
      offset     = options.delete(:offset)
      conditions = options.delete(:conditions) || options

      [conditions, order, limit, offset]
    end

    # given an order argument, returns an array of pairs, with each pair containing the attribute, and :asc or :desc
    def normalize_order(order)
      order = Array(order)

      if order.length == 2 && !order[0].is_a?(Array) && [:asc, :desc].include?(order[1])
        order = [order]
      else
        order = order.map {|pair| pair.is_a?(Array) ? pair : [pair, :asc] }
      end

      order.each do |pair|
        pair.length == 2 or raise ArgumentError, "each order clause must be a pair (unknown clause #{pair.inspect})"
        [:asc, :desc].include?(pair[1]) or raise ArgumentError, "order must be specified with :asc or :desc (unknown key #{pair[1].inspect})"
      end

      order
    end
  end

  class NotSupportedError < NotImplementedError
    def to_s
      "method not supported by this orm adapter"
    end
  end
end
