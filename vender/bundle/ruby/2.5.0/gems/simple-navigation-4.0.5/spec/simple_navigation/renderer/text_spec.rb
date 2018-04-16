module SimpleNavigation
  module Renderer
    describe Text do
      let!(:navigation) { setup_navigation('nav_id', 'nav_class') }

      let(:item) { nil }
      let(:options) {{ level: :all }}
      let(:output) { renderer.render(navigation) }
      let(:renderer) { Text.new(options) }

      before { select_an_item(navigation[item]) if item }

      describe '#render' do
        context 'when no item is selected' do
          it 'renders an empty string' do
            expect(output).to eq ''
          end
        end

        context 'when an item is selected' do
          let(:item) { :invoices }

          it "renders the selected item's name" do
            expect(output).to eq 'Invoices'
          end
        end

        context 'when a sub navigation item is selected' do
          before do
            allow(navigation[:invoices]).to receive_messages(selected?: true)

            allow(navigation[:invoices].sub_navigation[:unpaid]).to \
              receive_messages(selected?: true, selected_by_condition?: true)
          end

          it 'separates the items with a space' do
            expect(output).to eq 'Invoices Unpaid'
          end

          context "and the :join_with option is set" do
            let(:options) {{ level: :all, join_with: ' | ' }}

            it 'separates the items with the specified separator' do
              expect(output).to eq 'Invoices | Unpaid'
            end
          end
        end
      end
    end
  end
end
