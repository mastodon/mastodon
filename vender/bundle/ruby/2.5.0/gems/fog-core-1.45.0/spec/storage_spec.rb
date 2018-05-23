require "spec_helper"

module Fog
  module Storage
    def self.require(*_args); end
  end
end

describe "Fog::Storage" do
  describe "#new" do
    module Fog
      module TheRightWay
        extend Provider
        service(:storage, "Storage")
      end
    end

    module Fog
      module Storage
        class TheRightWay
          def initialize(_args); end
        end
      end
    end

    it "instantiates an instance of Fog::Storage::<Provider> from the :provider keyword arg" do
      compute = Fog::Storage.new(:provider => :therightway)
      assert_instance_of(Fog::Storage::TheRightWay, compute)
    end

    module Fog
      module TheWrongWay
        extend Provider
        service(:storage, "Storage")
      end
    end

    module Fog
      module TheWrongWay
        class Storage
          def initialize(_args); end
        end
      end
    end

    it "instantiates an instance of Fog::<Provider>::Storage from the :provider keyword arg" do
      compute = Fog::Storage.new(:provider => :thewrongway)
      assert_instance_of(Fog::TheWrongWay::Storage, compute)
    end

    module Fog
      module BothWays
        extend Provider
        service(:storage, "Storage")
      end
    end

    module Fog
      module BothWays
        class Storage
          def initialize(_args); end
        end
      end
    end

    module Fog
      module Storage
        class BothWays
          attr_reader :args

          def initialize(args)
            @args = args
          end
        end
      end
    end

    describe "when both Fog::Storage::<Provider> and Fog::<Provider>::Storage exist" do
      it "prefers Fog::Storage::<Provider>" do
        compute = Fog::Storage.new(:provider => :bothways)
        assert_instance_of(Fog::Storage::BothWays, compute)
      end
    end

    it "passes the supplied keyword args less :provider to Fog::Storage::<Provider>#new" do
      compute = Fog::Storage.new(:provider => :bothways, :extra => :stuff)
      assert_equal({ :extra => :stuff }, compute.args)
    end

    it "raises ArgumentError when given a :provider where a Fog::Storage::Provider that does not exist" do
      assert_raises(ArgumentError) do
        Fog::Storage.new(:provider => :wat)
      end
    end
  end

  describe ".get_body_size" do
    it "doesn't alter the encoding of the string passed to it" do
      # Ruby 1.8 doesn't support string encodings, so we can't test that
      if RUBY_VERSION >= "1.9.3"
        body = "foo".encode("UTF-8")
        Fog::Storage.get_body_size(body)

        assert_equal("UTF-8", body.encoding.to_s)
      else
        skip
      end
    end

    it "respects frozen strings" do
      if RUBY_VERSION >= "2.3.0"
        body = "foo".freeze
        Fog::Storage.get_body_size(body)
      else
        skip
      end
    end
  end
end