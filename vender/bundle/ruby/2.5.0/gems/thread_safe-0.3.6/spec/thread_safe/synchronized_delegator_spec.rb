require 'thread_safe/synchronized_delegator.rb'

module ThreadSafe
  describe SynchronizedDelegator do 
    it 'wraps array' do
      array = ::Array.new
      sync_array = described_class.new(array)

      array << 1
      expect(1).to eq sync_array[0]

      sync_array << 2
      expect(2).to eq array[1]
    end

    it 'synchronizes access' do
      t1_continue, t2_continue = false, false

      hash = ::Hash.new do |hash, key|
        t2_continue = true
        unless hash.find { |e| e[1] == key.to_s } # just to do something
          hash[key] = key.to_s
          Thread.pass until t1_continue
        end
      end
      sync_hash = described_class.new(hash)
      sync_hash[1] = 'egy'

      t1 = Thread.new do
        sync_hash[2] = 'dva'
        sync_hash[3] # triggers t2_continue
      end

      t2 = Thread.new do
        Thread.pass until t2_continue
        sync_hash[4] = '42'
      end

      sleep(0.05) # sleep some to allow threads to boot

      until t2.status == 'sleep' do
        Thread.pass
      end

      expect(3).to eq hash.keys.size

      t1_continue = true
      t1.join; t2.join

      expect(4).to eq sync_hash.size
    end

    it 'synchronizes access with block' do
      t1_continue, t2_continue = false, false

      array = ::Array.new
      sync_array = described_class.new(array)

      t1 = Thread.new do
        sync_array << 1
        sync_array.each do
          t2_continue = true
          Thread.pass until t1_continue
        end
      end

      t2 = Thread.new do
        # sleep(0.01)
        Thread.pass until t2_continue
        sync_array << 2
      end

      until t2.status == 'sleep' || t2.status == false
        Thread.pass
      end

      expect(1).to eq array.size

      t1_continue = true
      t1.join; t2.join

      expect([1, 2]).to eq array
    end
  end
end