class << MIME::Types
  include Enumerable

  ##
  def new(*) # :nodoc:
    super.tap do |types|
      __instances__.add types
    end
  end

  # MIME::Types#[] against the default MIME::Types registry.
  def [](type_id, complete: false, registered: false)
    __types__[type_id, complete: complete, registered: registered]
  end

  # MIME::Types#count against the default MIME::Types registry.
  def count
    __types__.count
  end

  # MIME::Types#each against the default MIME::Types registry.
  def each
    if block_given?
      __types__.each { |t| yield t }
    else
      enum_for(:each)
    end
  end

  # MIME::Types#type_for against the default MIME::Types registry.
  def type_for(filename)
    __types__.type_for(filename)
  end
  alias_method :of, :type_for

  # MIME::Types#add against the default MIME::Types registry.
  def add(*types)
    __types__.add(*types)
  end

  private

  def lazy_load?
    (lazy = ENV['RUBY_MIME_TYPES_LAZY_LOAD']) && (lazy != 'false')
  end

  def __types__
    (defined?(@__types__) and @__types__) or load_default_mime_types
  end

  unless private_method_defined?(:load_mode)
    def load_mode
      { columnar: true }
    end
  end

  def load_default_mime_types(mode = load_mode)
    @__types__ = MIME::Types::Cache.load
    unless @__types__
      @__types__ = MIME::Types::Loader.load(mode)
      MIME::Types::Cache.save(@__types__)
    end
    @__types__
  end

  def __instances__
    @__instances__ ||= Set.new
  end

  def reindex_extensions(type)
    __instances__.each do |instance|
      instance.send(:reindex_extensions!, type)
    end
    true
  end
end

##
class MIME::Types
  load_default_mime_types(load_mode) unless lazy_load?
end
