require "spec_helper"

module Fog
  module Compute
    def self.require(*_args); end
  end
end

describe "Fog::Compute" do
  describe "#new" do
    module Fog
      module TheRightWay
        extend Provider
        service(:compute, "Compute")
      end
    end

    module Fog
      module Compute
        class TheRightWay
          def initialize(_args); end
        end
      end
    end

    it "instantiates an instance of Fog::Compute::<Provider> from the :provider keyword arg" do
      compute = Fog::Compute.new(:provider => :therightway)
      assert_instance_of(Fog::Compute::TheRightWay, compute)
    end

    module Fog
      module TheWrongWay
        extend Provider
        service(:compute, "Compute")
      end
    end

    module Fog
      module TheWrongWay
        class Compute
          def initialize(_args); end
        end
      end
    end

    it "instantiates an instance of Fog::<Provider>::Compute from the :provider keyword arg" do
      compute = Fog::Compute.new(:provider => :thewrongway)
      assert_instance_of(Fog::TheWrongWay::Compute, compute)
    end

    module Fog
      module BothWays
        extend Provider
        service(:compute, "Compute")
      end
    end

    module Fog
      module BothWays
        class Compute
          def initialize(_args); end
        end
      end
    end

    module Fog
      module Compute
        class BothWays
          attr_reader :args
          def initialize(args)
            @args = args
          end
        end
      end
    end

    describe "when both Fog::Compute::<Provider> and Fog::<Provider>::Compute exist" do
      it "prefers Fog::Compute::<Provider>" do
        compute = Fog::Compute.new(:provider => :bothways)
        assert_instance_of(Fog::Compute::BothWays, compute)
      end
    end

    it "passes the supplied keyword args less :provider to Fog::Compute::<Provider>#new" do
      compute = Fog::Compute.new(:provider => :bothways, :extra => :stuff)
      assert_equal({ :extra => :stuff }, compute.args)
    end

    it "raises ArgumentError when given a :provider where a Fog::Compute::Provider that does not exist" do
      assert_raises(ArgumentError) do
        Fog::Compute.new(:provider => :wat)
      end
    end
  end
end
