module ThreadSafe
  describe Hash do 
    let!(:hsh) { described_class.new }

    it 'concurrency' do
      (1..THREADS).map do |i|
        Thread.new do
          1000.times do |j|
            hsh[i * 1000 + j] = i
            hsh[i * 1000 + j]
            hsh.delete(i * 1000 + j)
          end
        end
      end.map(&:join)
    end
  end
end