require 'helper'

class FilterWithDispatcherMixin
  include Temple::Mixins::Dispatcher

  def on_test(arg)
    [:on_test, arg]
  end

  def on_test_check(arg)
    [:on_check, arg]
  end

  def on_second_test(arg)
    [:on_second_test, arg]
  end

  def on_a_b(*arg)
    [:on_ab, *arg]
  end

  def on_a_b_test(arg)
    [:on_ab_test, arg]
  end

  def on_a_b_c_d_test(arg)
    [:on_abcd_test, arg]
  end
end

class FilterWithDispatcherMixinAndOn < FilterWithDispatcherMixin
  def on(*args)
    [:on_zero, *args]
  end
end

describe Temple::Mixins::Dispatcher do
  before do
    @filter = FilterWithDispatcherMixin.new
  end

  it 'should return unhandled expressions' do
    @filter.call([:unhandled]).should.equal [:unhandled]
  end

  it 'should dispatch first level' do
    @filter.call([:test, 42]).should.equal [:on_test, 42]
  end

  it 'should dispatch second level' do
    @filter.call([:second, :test, 42]).should.equal [:on_second_test, 42]
  end

  it 'should dispatch second level if prefixed' do
    @filter.call([:test, :check, 42]).should.equal [:on_check, 42]
  end

  it 'should dispatch parent level' do
    @filter.call([:a, 42]).should == [:a, 42]
    @filter.call([:a, :b, 42]).should == [:on_ab, 42]
    @filter.call([:a, :b, :test, 42]).should == [:on_ab_test, 42]
    @filter.call([:a, :b, :c, 42]).should == [:on_ab, :c, 42]
    @filter.call([:a, :b, :c, :d, 42]).should == [:on_ab, :c, :d, 42]
    @filter.call([:a, :b, :c, :d, :test, 42]).should == [:on_abcd_test, 42]
  end

  it 'should dispatch zero level' do
    FilterWithDispatcherMixinAndOn.new.call([:foo,42]).should == [:on_zero, :foo, 42]
  end
end
