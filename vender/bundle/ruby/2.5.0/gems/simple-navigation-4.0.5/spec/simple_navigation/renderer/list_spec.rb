module SimpleNavigation
  module Renderer
    describe List do
      let!(:navigation) { setup_navigation('nav_id', 'nav_class') }

      let(:item) { nil }
      let(:options) {{ level: :all }}
      let(:output) { HTML::Document.new(raw_output).root }
      let(:raw_output) { renderer.render(navigation) }
      let(:renderer) { List.new(options) }

      before { select_an_item(navigation[item]) if item }

      describe '#render' do
        it "renders an 'ul' tag for the navigation" do
          expect(output).to have_css('ul')
        end

        it "sets the right html id on the rendered 'ul' tag" do
          expect(output).to have_css('ul#nav_id')
        end

        it "sets the right html classes on the rendered 'ul' tag" do
          expect(output).to have_css('ul.nav_class')
        end

        context 'when an item has no specified id' do
          it "renders the item's 'li' tag with the item's stingified key as id" do
            expect(output).to have_css('li#invoices')
          end
        end

        context 'when an item has a specified id' do
          it "renders the item's 'li' tag with the specified id" do
            expect(output).to have_css('li#users_id')
          end
        end

        context 'when no item is selected' do
          it "renders each item as 'li' tag without any selected class" do
            expect(output).not_to have_css('ul li.selected')
          end

          it "renders each item as 'a' tag without any selected class" do
            expect(output).not_to have_css('ul li a.selected')
          end
        end

        context 'when an item is selected' do
          let(:item) { :invoices }

          it "renders the item's 'li' tag with its id and selected classes" do
            expect(output).to have_css('li#invoices.selected')
          end

          it "renders the item's 'a' tag with the selected classes" do
            expect(output).to have_css('li#invoices a.selected')
          end
        end

        context 'when the :ordered option is true' do
          let(:options) {{ level: :all, ordered: true }}

          it "renders an 'ol' tag for the navigation" do
            expect(output).to have_css('ol')
          end

          it "sets the right html id on the rendered 'ol' tag" do
            expect(output).to have_css('ol#nav_id')
          end

          it "sets the right html classes on the rendered 'ol' tag" do
            expect(output).to have_css('ol.nav_class')
          end
        end

        context 'when a sub navigation item is selected' do
          before do
            allow(navigation[:invoices]).to receive_messages(selected?: true)

            allow(navigation[:invoices].sub_navigation[:unpaid]).to \
              receive_messages(selected?: true, selected_by_condition?: true)
          end

          it 'renders the parent items as selected' do
            expect(output).to have_css('li#invoices.selected')
          end

          it "renders the selected nested item's link as selected" do
            expect(output).to have_css('li#unpaid.selected')
          end
        end
      end
    end
  end
end
