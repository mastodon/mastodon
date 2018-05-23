require 'spec_helper'

describe Hitimes::MutexedStats do
  before( :each ) do
    @threads = 5
    @iters   = 10_000
    @final_value = @threads * @iters
  end

  def run_with_scissors( stats, threads, iters )
    spool = []
    threads.times do |t|
      spool << Thread.new { iters.times{ stats.update( 1 ) } }
    end
    spool.each { |t| t.join }
    return stats
  end

  if (not defined? RUBY_ENGINE) or (RUBY_ENGINE == "ruby") then
    it "Hitimes::Stats is threadsafe" do
      stats = run_with_scissors( ::Hitimes::Stats.new, @threads, @iters )
      stats.count.must_equal @final_value
    end
  else
    it "Hitimes::Stats is not threadsafe" do
      stats = run_with_scissors( ::Hitimes::Stats.new, @threads, @iters )
      stats.count.wont_equal @final_value
    end
  end

  it "has a threadsafe update" do
    stats = run_with_scissors( ::Hitimes::MutexedStats.new, @threads, @iters )
    stats.count.must_equal @final_value
  end

end
