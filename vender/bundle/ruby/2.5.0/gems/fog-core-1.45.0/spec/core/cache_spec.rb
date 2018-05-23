require "spec_helper"
require "securerandom"
require "tmpdir"

module Fog
  class SubFogTestModel < Fog::Model
    identity  :id
  end
end

module Fog
  class SubFogTestService < Fog::Service

    class Mock
      attr_reader :options

      def initialize(opts = {})
        @options = opts
      end
    end
  end
end

describe Fog::Cache do
  before(:each) do
    Fog.mock!
    @service = Fog::SubFogTestService.new
    Fog::Cache.namespace_prefix = "test-dir"
  end

  it "has a namespace_prefix configurable" do
    Fog::Cache.namespace_prefix = "for-service-user-region-foo"

    # Expand path does not downcase. case insensitive platform tests.
    example_cache = File.expand_path(Fog::Cache.namespace(Fog::SubFogTestModel, @service)).downcase
    expected_namespace = File.expand_path("~/.fog-cache/for-service-user-region-foo").downcase

    assert_equal example_cache.include?(expected_namespace), true
  end

  it "has metadata associated to the namespace that you can save to" do
    Fog::Cache.clean!
    Fog::Cache.namespace_prefix = "for-service-user-region-foo"
    # nothing exists, nothing comes back
    assert_equal Fog::Cache.metadata, {}
    # write/read
    Fog::Cache.write_metadata({:last_dumped => "Tuesday, November 8, 2016"})
    assert_equal Fog::Cache.metadata[:last_dumped], "Tuesday, November 8, 2016"

    # diff namespace, diff metadata
    Fog::Cache.namespace_prefix = "different-namespace"
    assert_nil Fog::Cache.metadata[:last_dumped]
    # still accessible per namespace
    Fog::Cache.namespace_prefix = "for-service-user-region-foo"
    assert_equal Fog::Cache.metadata[:last_dumped],  "Tuesday, November 8, 2016"
    # can overwrite
    Fog::Cache.write_metadata({:last_dumped => "Diff date"})
    assert_equal Fog::Cache.metadata[:last_dumped],  "Diff date"

    # can't write a non-hash/data entry.
    assert_raises Fog::Cache::CacheDir do
      Fog::Cache.write_metadata("boo")
    end

    # namespace must be set as well.
    assert_raises Fog::Cache::CacheDir do
      Fog::Cache.namespace_prefix = nil
      Fog::Cache.write_metadata({:a => "b"})
    end

 end

  it "can load cache data from disk" do
    path = File.expand_path("~/.fog-cache-test-#{Time.now.to_i}.yml")
    data = "--- ok\n...\n"
    File.open(path, "w") { |f|
      f.write(data)
    }

    assert_equal "ok", Fog::Cache.load_cache(path)
  end

  it "load bad cache data - empty file, from disk" do
    path = File.expand_path("~/.fog-cache-test-2-#{Time.now.to_i}.yml")
    data = ""
    File.open(path, "w") { |f|
      f.write(data)
    }

    assert_equal false, Fog::Cache.load_cache(path)
  end

  it "must have a namespace_prefix configurable" do
    Fog::Cache.namespace_prefix = nil
    assert_raises Fog::Cache::CacheDir do
      Fog::Cache.load(Fog::SubFogTestModel, @service)
    end
  end

  it "can create a namespace" do
    Fog::Cache.expire_cache!(Fog::SubFogTestModel, @service)
    assert_equal File.exist?(Fog::Cache.namespace(Fog::SubFogTestModel, @service)), false

    Fog::Cache.create_namespace(Fog::SubFogTestModel, @service)
    assert_equal File.exist?(Fog::Cache.namespace(Fog::SubFogTestModel, @service)), true
  end

  it "will raise if no cache data found" do
    Fog::Cache.expire_cache!(Fog::SubFogTestModel, @service)

    assert_raises Fog::Cache::CacheNotFound do
      Fog::Cache.load(Fog::SubFogTestModel, @service)
    end
  end

  it "Fog cache ignores bad cache data - empty file, from disk" do
    Fog::Cache.expire_cache!(Fog::SubFogTestModel, @service)
    id = SecureRandom.hex
    a = Fog::SubFogTestModel.new(:id => id, :service => @service)
    a.cache.dump

    # input bad data
    path_dir = File.expand_path(Fog::Cache.namespace(Fog::SubFogTestModel, @service))
    path = File.join(path_dir, "foo.yml")
    data = ""
    File.open(path, "w") { |f|
      f.write(data)
    }

    assert_equal 1, Fog::Cache.load(Fog::SubFogTestModel, @service).size
  end


  it "can be dumped and reloaded back in" do

    Fog::Cache.expire_cache!(Fog::SubFogTestModel, @service)

    id = SecureRandom.hex
    a = Fog::SubFogTestModel.new(:id => id, :service => @service)

    assert_equal File.exist?(Fog::Cache.namespace(Fog::SubFogTestModel, @service)), false
    a.cache.dump
    assert_equal File.exist?(Fog::Cache.namespace(Fog::SubFogTestModel, @service)), true

    instances = Fog::Cache.load(Fog::SubFogTestModel, @service)

    assert_equal instances.first.id, a.id
    assert_equal instances.first.class, a.class
  end

  it "dumping two models that have a duplicate identity" do
    Fog::Cache.expire_cache!(Fog::SubFogTestModel, @service)

    id = SecureRandom.hex

    # security groups on aws for eg can have the same identity group name 'default'.
    # there are no restrictions on `identity` fog attributes to be uniq.
    a = Fog::SubFogTestModel.new(:id => id, :service => @service, :bar => 'bar')
    b = Fog::SubFogTestModel.new(:id => id, :service => @service, :foo => 'foo')

    a.cache.dump
    b.cache.dump

    instances = Fog::Cache.load(Fog::SubFogTestModel, @service)

    assert_equal instances.size, 2
  end

  it "dumping two models that have a duplicate identity twice" do
    Fog::Cache.expire_cache!(Fog::SubFogTestModel, @service)

    id = SecureRandom.hex

    # security groups on aws for eg can have the same identity group name 'default'.
    # there are no restrictions on `identity` fog attributes to be uniq.
    a = Fog::SubFogTestModel.new(:id => id, :service => @service, :bar => 'bar')
    b = Fog::SubFogTestModel.new(:id => id, :service => @service, :foo => 'foo')

    a.cache.dump
    b.cache.dump

    # and then again, w/out expiring cache
    a.cache.dump
    b.cache.dump

    instances = Fog::Cache.load(Fog::SubFogTestModel, @service)

    # unique-ify based on the attributes...
    assert_equal instances.size, 2
  end
end
