module ThreadSafe
  describe Array do
    let!(:ary) { described_class.new }

    it 'concurrency' do
      (1..THREADS).map do |i|
        Thread.new do
          1000.times do
            ary << i
            ary.each { |x| x * 2 }
            ary.shift
            ary.last
          end
        end
      end.map(&:join)
    end
  end
end