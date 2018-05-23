module SimpleNavigation
  describe ItemAdapter do
    let(:item_adapter) { ItemAdapter.new(item) }

    context 'when item is an object' do
      let(:item) { double(:item, key: 'key', name: 'name', url: 'url') }

      shared_examples 'delegating to item' do |meth|
        it "delegates #{meth} to item" do
          expect(item).to receive(meth)
          item_adapter.public_send(meth)
        end
      end

      it_behaves_like 'delegating to item', :key
      it_behaves_like 'delegating to item', :url
      it_behaves_like 'delegating to item', :name

      describe '#initialize' do
        it 'sets the item' do
          expect(item_adapter.item).to be item
        end
      end

      describe '#options' do
        context 'when item responds to options' do
          let(:options) { double(:options) }

          before { allow(item).to receive_messages(options: options) }

          it "returns the item's options" do
            expect(item_adapter.options).to be options
          end
        end

        context 'item does not respond to options' do
          it 'returns an empty hash' do
            expect(item_adapter.options).to eq({})
          end
        end
      end

      describe '#items' do
        context 'when item responds to items' do
          context 'and items is nil' do
            before { allow(item).to receive_messages(items: nil) }

            it 'returns nil' do
              expect(item_adapter.items).to be_nil
            end
          end

          context 'when items is not nil' do
            context 'and items is empty' do
              before { allow(item).to receive_messages(items: []) }

              it 'returns nil' do
                expect(item_adapter.items).to be_nil
              end
            end

            context 'and items is not empty' do
              let(:items) { [true] }

              before { allow(item).to receive_messages(items: items) }

              it 'returns the items' do
                expect(item_adapter.items).to eq items
              end
            end
          end
        end

        context "when item doesn't respond to items" do
          it 'returns nil' do
            expect(item_adapter.items).to be_nil
          end
        end
      end

      describe '#to_simple_navigation_item' do
        let(:container) { double(:container) }

        before { allow(item).to receive_messages(items: [], options: {}) }

        it 'creates an Item' do
          expect(Item).to receive(:new)
                          .with(container, 'key', 'name', 'url', {})
          item_adapter.to_simple_navigation_item(container)
        end
      end
    end

    context 'when item is a kind of hash' do
      class ModifiedHash < Hash; end

      let(:item) { ModifiedHash[key: 'key', url: 'url', name: 'name'] }

      shared_examples 'delegating to item' do |meth|
        it "delegates #{meth} to item" do
          expect(item_adapter.item).to receive(meth)
          item_adapter.public_send(meth)
        end
      end

      it_behaves_like 'delegating to item', :key
      it_behaves_like 'delegating to item', :url
      it_behaves_like 'delegating to item', :name

      describe '#initialize' do
        it 'sets the item' do
          expect(item_adapter.item).not_to be_nil
        end

        it 'converts the item into an object' do
          expect(item_adapter.item).to respond_to(:url)
        end
      end

      describe '#options' do
        context 'when item responds to options' do
          before { item[:options] = { my: :options } }

          it "returns the item's options" do
            expect(item_adapter.options).to eq({ my: :options })
          end
        end

        context 'when item does not respond to options' do
          it 'returns an empty hash' do
            expect(item_adapter.options).to eq({})
          end
        end
      end

      describe '#items' do
        context 'when item responds to items' do
          context 'and items is nil' do
            before { item[:items] = nil }

            it 'returns nil' do
              expect(item_adapter.items).to be_nil
            end
          end

          context 'when items is not nil' do
            context 'and items is empty' do
              it 'returns nil' do
                expect(item_adapter.items).to be_nil
              end
            end

            context 'and items is not empty' do
              before { item[:items] = ['not', 'empty'] }

              it 'returns the items' do
                expect(item_adapter.items).to eq ['not', 'empty']
              end
            end
          end
        end

        context 'when item does not respond to items' do
          it 'returns nil' do
            expect(item_adapter.items).to be_nil
          end
        end
      end

      describe '#to_simple_navigation_item' do
        let(:container) { double(:container) }

        before { item.merge(options: {}) }

        it 'passes the right arguments to Item' do
          expect(Item).to receive(:new)
                          .with(container, 'key', 'name', 'url', {})
          item_adapter.to_simple_navigation_item(container)
        end

        it 'creates an Item' do
          created_item = item_adapter.to_simple_navigation_item(container)
          expect(created_item).to be_an(Item)
        end
      end
    end
  end
end
