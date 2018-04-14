require "spec_helper"

module Fog
  module Identity
    def self.require(*_args); end
  end
end

describe "Fog::Identity" do
  describe "#new" do
    module Fog
      module TheRightWay
        extend Provider
        service(:identity, "Identity")
      end
    end

    module Fog
      module Identity
        class TheRightWay
          def initialize(_args); end
        end
      end
    end

    it "instantiates an instance of Fog::Identity::<Provider> from the :provider keyword arg" do
      identity = Fog::Identity.new(:provider => :therightway)
      assert_instance_of(Fog::Identity::TheRightWay, identity)
    end

    module Fog
      module Rackspace
        extend Provider
        service(:identity, "Identity")
      end
    end

    module Fog
      module Rackspace
        class Identity
          def initialize(_args); end
        end
      end
    end

    it "instantiates an instance of Fog::<Provider>::Identity from the :provider keyword arg" do
      identity = Fog::Identity.new(:provider => :rackspace)
      assert_instance_of(Fog::Rackspace::Identity, identity)
    end

    module Fog
      module BothWays
        extend Provider
        service(:identity, "Identity")
      end
    end

    module Fog
      module BothWays
        class Identity
          def initialize(_args); end
        end
      end
    end

    module Fog
      module Identity
        class BothWays
          attr_reader :args
          def initialize(args)
            @args = args
          end
        end
      end
    end

    describe "when both Fog::Identity::<Provider> and Fog::<Provider>::Identity exist" do
      it "prefers Fog::Identity::<Provider>" do
        identity = Fog::Identity.new(:provider => :bothways)
        assert_instance_of(Fog::Identity::BothWays, identity)
      end
    end

    it "passes the supplied keyword args less :provider to Fog::Identity::<Provider>#new" do
      identity = Fog::Identity.new(:provider => :bothways, :extra => :stuff)
      assert_equal({ :extra => :stuff }, identity.args)
    end

    it "raises ArgumentError when given a :provider where a Fog::Identity::Provider that does not exist" do
      assert_raises(ArgumentError) do
        Fog::Identity.new(:provider => :wat)
      end
    end
  end
end
