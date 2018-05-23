describe Wisper do
  describe '.subscribe' do
    context 'when given block' do

      it 'subscribes listeners to all events for duration of the block' do
        publisher = publisher_class.new
        listener  = double('listener')

        expect(listener).to receive(:first_event)
        expect(listener).not_to receive(:second_event)

        Wisper.subscribe(listener) do
          publisher.send(:broadcast, 'first_event')
        end

        publisher.send(:broadcast, 'second_event')
      end
    end

    context 'when no block given' do
      it 'subscribes listener to all events' do
        listener = double('listener')
        Wisper.subscribe(listener)
        expect(Wisper::GlobalListeners.listeners).to eq [listener]
      end

      it 'subscribes listeners to all events' do
        listener_1 = double('listener')
        listener_2 = double('listener')

        Wisper.subscribe(listener_1, listener_2)

        expect(Wisper::GlobalListeners.listeners).to include listener_1, listener_2
      end
    end
  end

  describe '.unsubscribe' do
    it 'removes listener from list of listeners' do
      listener = double('listener')

      Wisper.subscribe(listener)
      expect(Wisper::GlobalListeners.listeners).to eq [listener]

      Wisper.unsubscribe(listener)
      expect(Wisper::GlobalListeners.listeners).to eq []
    end

    it 'removes listeners from list of listeners' do
      listener_1 = double('listener')
      listener_2 = double('listener')

      Wisper.subscribe(listener_1, listener_2)
      expect(Wisper::GlobalListeners.listeners).to include listener_1, listener_2

      Wisper.unsubscribe(listener_1, listener_2)
      expect(Wisper::GlobalListeners.listeners).to eq []
    end
  end

  describe '.publisher' do
    it 'returns the Publisher module' do
      expect(Wisper.publisher).to eq Wisper::Publisher
    end
  end

  describe '.clear' do
    before { Wisper.subscribe(double) }

    it 'clears all global listeners' do
      Wisper.clear
      expect(Wisper::GlobalListeners.listeners).to be_empty
    end
  end

  describe '.configuration' do
    it 'returns configuration object' do
      expect(Wisper.configuration).to be_an_instance_of(Wisper::Configuration)
    end

    it 'is memorized' do
      expect(Wisper.configuration).to eq Wisper.configuration
    end
  end

  describe '.configure' do
    it 'passes configuration to given block' do
      Wisper.configure do |config|
        expect(config).to be_an_instance_of(Wisper::Configuration)
      end
    end
  end

  describe '.setup' do
    it 'sets a default broadcaster' do
      expect(Wisper.configuration.broadcasters[:default]).to be_instance_of(Wisper::Broadcasters::SendBroadcaster)
    end
  end
end
