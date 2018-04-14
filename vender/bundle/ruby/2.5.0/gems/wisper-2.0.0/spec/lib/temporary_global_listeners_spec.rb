describe Wisper::TemporaryListeners do
  let(:listener_1) { double('listener', :to_a => nil) } # [1]
  let(:listener_2) { double('listener', :to_a => nil) }

  let(:publisher)  { publisher_class.new }

  describe '.subscribe' do
    it 'globally subscribes listener for duration of given block' do

      expect(listener_1).to receive(:success)
      expect(listener_1).to_not receive(:failure)

      Wisper::TemporaryListeners.subscribe(listener_1) do
        publisher.instance_eval { broadcast(:success) }
      end

      publisher.instance_eval { broadcast(:failure) }
    end

    it 'globally subscribes listeners for duration of given block' do

      expect(listener_1).to receive(:success)
      expect(listener_1).to_not receive(:failure)

      expect(listener_2).to receive(:success)
      expect(listener_2).to_not receive(:failure)

      Wisper::TemporaryListeners.subscribe(listener_1, listener_2) do
        publisher.instance_eval { broadcast(:success) }
      end

      publisher.instance_eval { broadcast(:failure) }
    end

    it 'is thread safe' do
      num_threads = 20
      (1..num_threads).to_a.map do
        Thread.new do
          Wisper::TemporaryListeners.registrations << Object.new
          expect(Wisper::TemporaryListeners.registrations.size).to eq 1
        end
      end.each(&:join)

      expect(Wisper::TemporaryListeners.registrations).to be_empty
    end

    it 'clears registrations when an exception occurs' do
      MyError = Class.new(StandardError)

      begin
        Wisper::TemporaryListeners.subscribe(listener_1) do
          raise MyError
        end
      rescue MyError
      end

      expect(Wisper::TemporaryListeners.registrations).to be_empty
    end

    it 'returns self' do
      expect(Wisper::TemporaryListeners.subscribe {}).to be_an_instance_of(Wisper::TemporaryListeners)
    end
  end
end

# [1] stubbing `to_a` prevents `Double "listener" received unexpected message
# :to_a with (no args)` on MRI 1.9.2 when a double is passed to `Array()`.
