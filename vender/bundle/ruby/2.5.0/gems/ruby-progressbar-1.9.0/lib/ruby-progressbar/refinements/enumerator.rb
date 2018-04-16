class  ProgressBar
module Refinements
module Enumerator
refine ::Enumerator do
  # rubocop:disable Metrics/BlockNesting
  def with_progressbar(options = {}, &block)
    chain = ::Enumerator.new do |yielder|
      progress_bar = ProgressBar.create(options.merge(:starting_at => 0, :total => size))

      each do |*args|
        yielder.yield(*args).tap do
          progress_bar.increment
        end
      end
    end

    return chain unless block_given?

    chain.each(&block)
  end
  # rubocop:enable Metrics/BlockNesting
end
end
end
end
