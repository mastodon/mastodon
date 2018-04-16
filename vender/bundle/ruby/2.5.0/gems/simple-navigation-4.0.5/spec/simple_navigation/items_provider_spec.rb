module SimpleNavigation
  describe ItemsProvider do
    let(:items_provider) { ItemsProvider.new(provider) }

    describe '#items' do
      let(:items) { double(:items) }

      context 'when provider is a symbol' do
        let(:context) { double(:context, provider_method: items) }
        let(:provider) { :provider_method }

        before { allow(SimpleNavigation).to receive_messages(context_for_eval: context) }

        it 'retrieves the items from the evaluation context' do
          expect(items_provider.items).to eq items
        end
      end

      context 'when provider responds to :items' do
        let(:provider) { double(:provider, items: items) }

        it 'retrieves the items from the provider object' do
          expect(items_provider.items).to eq items
        end
      end

      context 'provider is a collection' do
        let(:provider) { [] }

        it 'retrieves the items by returning the provider' do
          expect(items_provider.items).to eq provider
        end
      end

      context 'when provider is something else' do
        let(:provider) { double(:provider) }

        it 'raises an exception' do
          expect{ items_provider.items }.to raise_error
        end
      end
    end
  end
end
