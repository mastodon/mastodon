module SimpleNavigation
  module Renderer
    describe Links do
      describe '#render' do
        let!(:navigation) { setup_navigation('nav_id', 'nav_class') }

        let(:item) { nil }
        let(:options) {{ level: :all }}
        let(:output) { HTML::Document.new(raw_output).root }
        let(:raw_output) { renderer.render(navigation) }
        let(:renderer) { Links.new(options) }

        before { select_an_item(navigation[item]) if item }

        it "renders a 'div' tag for the navigation" do
          expect(output).to have_css('div')
        end

        it "sets the right html id on the rendered 'div' tag" do
          expect(output).to have_css('div#nav_id')
        end

        it "sets the right html classes on the rendered 'div' tag" do
          expect(output).to have_css('div.nav_class')
        end

        it "renders an 'a' tag for each item" do
          expect(output).to have_css('a', 3)
        end

        it "renders the 'a' tags with the corresponding item's :html_options" do
          expect(output).to have_css('a[style=float:right]')
        end

        context 'when an item has a specified id' do
          it "renders the 'a' tags with the specified id" do
            expect(output).to have_css('a#users_id')
          end
        end

        context 'when an item has no specified id' do
          it "uses a default id by stringifying the item's key" do
            expect(output).to have_css('a#invoices')
          end
        end

        context 'when no item is selected' do
          it "renders items without the 'selected' class" do
            expect(output).not_to have_css('a.selected')
          end
        end

        context 'when an item is selected' do
          let(:item) { :invoices }

          it "renders the selected item with the 'selected' class" do
            expect(output).to have_css('a#invoices.selected')
          end
        end

        context "when the :join_with option is set" do
          let(:options) {{ level: :all, join_with: ' | ' }}

          it 'separates the items with the specified separator' do
            expect(raw_output.scan(' | ').size).to eq 3
          end
        end

        context 'when a sub navigation item is selected' do
          before do
            allow(navigation[:invoices]).to receive_messages(selected?: true)

            allow(navigation[:invoices].sub_navigation[:unpaid]).to \
              receive_messages(selected?: true, selected_by_condition?: true)
          end

          it 'renders the main parent as selected' do
            expect(output).to have_css('a#invoices.selected')
          end

          it "doesn't render the nested item's link" do
            expect(output).not_to have_css('a#unpaid')
          end
        end
      end
    end
  end
end
