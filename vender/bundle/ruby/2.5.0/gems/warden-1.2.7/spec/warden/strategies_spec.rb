# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe Warden::Strategies do
  it "should let me add a strategy via a block" do
    Warden::Strategies.add(:strategy1) do
      def authenticate!
        success("foo")
      end
    end
    expect(Warden::Strategies[:strategy1].ancestors).to include(Warden::Strategies::Base)
  end

  it "should raise an error if I add a strategy via a block, that does not have an authenticate! method" do
    expect {
      Warden::Strategies.add(:strategy2) do
      end
    }.to raise_error(NoMethodError)
  end

  it "should raise an error if I add a strategy that does not extend Warden::Strategies::Base" do
    non_base = Class.new do
      def authenticate!
      end
    end
    expect do
      Warden::Strategies.add(:strategy_non_base, non_base)
    end.to raise_error(/is not a Warden::Strategies::Base/)
  end

  it "should allow me to get access to a particular strategy" do
    Warden::Strategies.add(:strategy3) do
      def authenticate!; end
    end
    strategy = Warden::Strategies[:strategy3]
    expect(strategy).not_to be_nil
    expect(strategy.ancestors).to include(Warden::Strategies::Base)
  end

  it "should allow me to add a strategy with the required methods" do
    class MyStrategy < Warden::Strategies::Base
      def authenticate!; end
    end

    expect {
      Warden::Strategies.add(:strategy4, MyStrategy)
    }.not_to raise_error
  end

  it "should not allow a strategy that does not have an authenticate! method" do
    class MyOtherStrategy
    end
    expect {
      Warden::Strategies.add(:strategy5, MyOtherStrategy)
    }.to raise_error(NoMethodError)
  end

  it "should allow me to change a class when providing a block and class" do
    class MyStrategy < Warden::Strategies::Base
    end

    Warden::Strategies.add(:foo, MyStrategy) do
      def authenticate!; end
    end

    expect(Warden::Strategies[:foo].ancestors).to include(MyStrategy)
  end

  it "should allow me to update a previously given strategy" do
    class MyStrategy < Warden::Strategies::Base
      def authenticate!; end
    end

    Warden::Strategies.add(:strategy6, MyStrategy)

    new_module = Module.new
    Warden::Strategies.update(:strategy6) do
      include new_module
    end

    expect(Warden::Strategies[:strategy6].ancestors).to include(new_module)
  end

  it "should allow me to clear the strategies" do
    Warden::Strategies.add(:foobar) do
      def authenticate!
        :foo
      end
    end
    expect(Warden::Strategies[:foobar]).not_to be_nil
    Warden::Strategies.clear!
    expect(Warden::Strategies[:foobar]).to be_nil
  end
end
