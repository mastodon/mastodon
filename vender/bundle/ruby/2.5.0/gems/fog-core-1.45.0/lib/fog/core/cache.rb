# coding: utf-8
require "fileutils"
require "yaml"
require "tmpdir"

module Fog
  # A generic cache mechanism for fog resources. This can be for a server, security group, etc.
  #
  # Currently this is a on-disk cache using yml files per-model instance, however
  # there is nothing in the way of extending this to use various other cache
  # backends.
  #
  # == Basic functionality
  #
  # set the namespace where this cache will be stored:
  #
  # Fog::Cache.namespace_prefix = "service-account-foo-region-bar"
  #
  # cache to disk:
  #
  #   # after dumping, there will be a yml file on disk:
  #   resouce.cache.dump
  #
  #   # you can load cached data in from a different session
  #   Fog::Cache.load(Fog::Compute::AWS::Server, compute)
  #
  #   # you can also expire cache (removes cached data assocaited with the resources of this model associated to the service passed in).
  #   Fog::Cache.expire_cache!(Fog::Compute::AWS::Server, compute)
  #
  # == More detailed flow/usage
  #
  # Normally, you would have a bunch of resources you want to cache/reload from disk.
  # Every fog model has a +cache+ object injected to accomplish this. So in order to cache a server for exmaple
  # you would do something like this:
  #
  #   # note this is necessary in order to segregate usage of cache between various providers regions and accounts.
  #   # if you are using one account/region/etc only, you still must set it. 'default' will do.
  #   Fog::Cache.namespace_prefix = "prod-emea-eu-west-1"
  #
  #   s = security_groups.sample; s.name # => "default"
  #   s.cache.dump # => 2371
  #
  # Now it is on disk:
  #
  # shai@adsk-lappy ~   % tree ~/.fog-cache/prod-emea-eu-west-1/
  #
  #   /Users/shai/.fog-cache/prod-emea-eu-west-1/
  #     └── fog_compute_aws_real
  #       └── fog_compute_aws_securitygroup
  #        ├── default-90928073d9d5d9b4e7545e88aee7ec4f.yml
  #
  # You can do the same with a SecurityGroup, Instances, Elbs, etc.
  #
  # Note that when loading cache from disk, you need to pass the appropriate model class, and service associated with it.
  # +Service+ is passed in is so that the service/connection details can be loaded into the loaded instances so they can be re-queried, etc.
  # +Model+ is passed in so we can find the cache data associated to that model in the namespace of cache this session is using:
  # Will try to load all resources associated to those. If you had 1 yml file, or 100, it would load whatever it could find.
  # As such, the normal usage of dumping would be do it on a collection:
  #
  #   load_balancers.each {|elb| elb.cache.dump }
  #
  # In order to load the cache into a different session with nothing but the service set up, use like so:
  # As mentioned, will load all resources associated to the +model_klass+ and +service+ passed in.
  #
  #   instances = Fog::Cache.load(Fog::Compute::AWS::Server, compute)
  #   instances.first.id # => "i-0569a70ae6f47d229"
  #
  # Note that if there is no cache located for the +model+ class and +service+ passed to `Fog::Cache.load`
  # you will get an exception you can handle (for example, to load the resources for the fisrt time):
  #
  #   Fog::Cache.expire_cache!(Fog::Compute::AWS::SecurityGroup, compute)
  #   # ... now there is no SecurityGroup cache data. So, if you tried to load it, you would get an exception:
  #
  #   Fog::Cache.load(Fog::Compute::AWS::SecurityGroup, compute)
  #     rescue Fog::Cache::CacheNotFound => e
  #       puts "could not find any cache data for security groups on #{compute}"
  #       get_resources_and_dump
  #
  # == Extending cache backends
  #
  # Currently this is on-disk using yml. If need be, this could be extended to other cache backends:
  #
  # Find references of yaml in this file, split out to strategy objects/diff backends etc.
  class Cache

    # cache associated not found
    class CacheNotFound < StandardError; end

    # cache directory problem
    class CacheDir < StandardError; end

    # where different caches per +service+ api keys, regions etc, are stored
    # see the +namespace_prefix=+ method.
    SANDBOX = ENV["HOME"] ? File.expand_path("~/.fog-cache") : File.expand_path(".fog-cache")

    # when a resource is used such as `server.cache.dump` the model klass is passed in
    # so that it can be identified from a different session.
    attr_reader :model

    # Loads cache associated to the +model_klass+ and +service+ into memory.
    #
    # If no cache is found, it will raise an error for handling:
    #
    #   rescue Fog::Cache::CacheNotFound
    #     set_initial_cache
    #
    def self.load(model_klass, service)
      cache_files = Dir.glob("#{namespace(model_klass, service)}/*")

      raise CacheNotFound if cache_files.empty?

      # collection_klass and model_klass should be the same across all instances
      # choose a valid cache record from the dump to use as a sample to deterine
      # which collection/model to instantiate.
      sample_path = cache_files.detect{ |path| valid_for_load?(path) }
      model_klass = const_get_compat(load_cache(sample_path)[:model_klass])
      collection_klass = const_get_compat(load_cache(sample_path)[:collection_klass]) if load_cache(sample_path)[:collection_klass]

      # Load the cache data into actual ruby instances
      loaded = cache_files.map do |path|
          model_klass.new(load_cache(path)[:attrs]) if valid_for_load?(path)
      end.compact

      # Set the collection and service so they can be reloaded/connection is set properly.
      # See https://github.com/fog/fog-aws/issues/354#issuecomment-286789702
      loaded.each do |i|
        i.collection = collection_klass.new(:service => service) if collection_klass
        i.instance_variable_set(:@service, service)
      end

      # uniqe-ify based on the total of attributes. duplicate cache can exist due to
      # `model#identity` not being unique. but if all attributes match, they are unique
      # and shouldn't be loaded again.
      uniq_loaded = uniq_w_block(loaded) { |i| i.attributes }
      if uniq_loaded.size != loaded.size
        Fog::Logger.warning("Found duplicate items in the cache. Expire all & refresh cache soon.")
      end

      # Fog models created, free memory of cached data used for creation.
      @memoized = nil

      uniq_loaded
    end

    # :nodoc: compatability for 1.8.7 1.9.3
    def self.const_get_compat(strklass)
      # https://stackoverflow.com/questions/3163641/get-a-class-by-name-in-ruby
      strklass.split('::').inject(Object) do |mod, class_name|
        mod.const_get(class_name)
      end
    end

    # :nodoc: compatability for 1.8.7 1.9.3
    def self.uniq_w_block(arr)
      ret, keys = [], []
      arr.each do |x|
        key = block_given? ? yield(x) : x
        unless keys.include? key
          ret << x
          keys << key
        end
      end
      ret
    end

    # method to determine if a path can be loaded and is valid fog cache format.
    def self.valid_for_load?(path)
      data = load_cache(path)
      if data && data.is_a?(Hash)
        if [:identity, :model_klass, :collection_klass, :attrs].all? { |k| data.keys.include?(k) }
          return true
        else
          Fog::Logger.warning("Found corrupt items in the cache: #{path}. Expire all & refresh cache soon.\n\nData:#{File.read(path)}")
          return false
        end
      end
    end

    # creates on-disk cache of this specific +model_klass+ and +@service+
    def self.create_namespace(model_klass, service)
      FileUtils.mkdir_p(self.namespace(model_klass, service))
    end

    # Expires cache - this does not expire all cache associated.
    # Instead, this will remove all on-disk cache of this specific +model_klass+ and and +@service+
    def self.expire_cache!(model_klass, service)
      FileUtils.rm_rf(namespace(model_klass, service))
    end

    # cleans the `SANDBOX` - specific any resource cache of any namespace,
    # and any metadata associated to any.
    def self.clean!
      FileUtils.rm_rf(SANDBOX)
    end

    # loads yml cache from path on disk, used
    # to initialize Fog models.
    def self.load_cache(path)
      @memoized ||= {}
      return @memoized[path] if @memoized[path]
      @memoized[path] = YAML.load(File.read(path))
    end

    def self.namespace_prefix=(name)
      @namespace_prefix = name
    end

    def self.namespace_prefix
      @namespace_prefix
    end

    # write any metadata - +hash+ information - specific to the namespaced cache in the session.
    #
    # you can retrieve this in other sessions, as long as +namespace_prefix+ is set
    # you can overwrite metadata over time. see test cases as examples.
    def self.write_metadata(h)
      if namespace_prefix.nil?
        raise CacheDir.new("Must set an explicit identifier/name for this cache. Example: 'serviceX-regionY'") unless namespace_prefix
      elsif !h.is_a?(Hash)
        raise CacheDir.new("metadta must be a hash of information like {:foo => 'bar'}")
      end

      mpath = File.join(SANDBOX, namespace_prefix, "metadata.yml")
      to_write = if File.exist?(mpath)
                YAML.dump(YAML.load(File.read(mpath)).merge!(h))
              else
                YAML.dump(h)
              end

      mdir = File.join(SANDBOX, namespace_prefix)
      FileUtils.mkdir_p(mdir) if !File.exist?(mdir)

      File.open(mpath, "w") { |f| f.write(to_write) }
    end

    # retrive metadata for this +namespace+ of cache. returns empty {} if none found.
    def self.metadata
      mpath = File.join(SANDBOX, namespace_prefix, "metadata.yml")
      if File.exist?(mpath)
        metadata = YAML.load(File.read(mpath))
        return metadata
      else
        return {}
      end
    end

    # The path/namespace where the cache is stored for a specific +model_klass+ and +@service+.
    def self.namespace(model_klass, service)

      raise CacheDir.new("Must set an explicit identifier/name for this cache. Example: 'serviceX-regionY'") unless namespace_prefix

      ns = File.join(SANDBOX, namespace_prefix, service.class.to_s, model_klass.to_s)
      ns = safe_path(ns)
    end

    def self.safe_path(klass)
      klass.to_s.gsub("::", "_").downcase
    end

    def initialize(model)
      @model = model
    end

    # Dump a Fog::Model resource. Every fog model/instance now has a +cache+ method/object injected in.
    # as such you can use the #dump method to save the attributes and metadata of that instance as cache
    # which can be re-used in some other session.
    def dump
      if !File.exist?(self.class.namespace(model.class, model.service))
        self.class.create_namespace(model.class, model.service)
      end

      data = { :identity => model.identity,
                     :model_klass => model.class.to_s,
                     :collection_klass => model.collection && model.collection.class.to_s,
                     :attrs => model.attributes }

      File.open(dump_to, "w") { |f| f.write(YAML.dump(data)) }
    end

    # the location of where to save this fog model/instance to.
    def dump_to
      # some fog models have an identity field that is duplicate.
      # duplicate identities can mean the cache for that already exists.
      # this means cache duplication is possible.
      #
      # see "dumping two models that have duplicate identity" test case.
      "#{self.class.namespace(model.class, model.service)}/#{model.identity}-#{SecureRandom.hex}.yml"
    end
  end
end
