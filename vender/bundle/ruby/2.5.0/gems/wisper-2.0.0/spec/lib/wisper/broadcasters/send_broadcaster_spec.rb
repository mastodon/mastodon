module Wisper
  module Broadcasters
    describe SendBroadcaster do
      let(:listener) { double('listener') }
      let(:event)      { 'thing_created' }

      describe '#broadcast' do
        context 'without arguments' do
          let(:args) { [] }

          it 'sends event to listener without any arguments' do
            expect(listener).to receive(event).with(no_args())
            subject.broadcast(listener, anything, event, args)
          end
        end

        context 'with arguments' do
          let(:args) { [1,2,3] }

          it 'sends event to listener with arguments' do
            expect(listener).to receive(event).with(*args)
            subject.broadcast(listener, anything, event, args)
          end
        end
      end
    end
  end
end
