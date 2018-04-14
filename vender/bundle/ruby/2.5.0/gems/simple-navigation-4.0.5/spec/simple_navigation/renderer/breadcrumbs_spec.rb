module SimpleNavigation
  module Renderer
    describe Breadcrumbs do
      let!(:navigation) { setup_navigation('nav_id', 'nav_class') }

      let(:item) { nil }
      let(:options) {{ level: :all }}
      let(:output) { HTML::Document.new(raw_output).root }
      let(:raw_output) { renderer.render(navigation) }
      let(:renderer) { Breadcrumbs.new(options) }

      before { select_an_item(navigation[item]) if item }

      describe '#render' do
        it "renders a 'div' tag for the navigation" do
          expect(output).to have_css('div')
        end

        it "sets the right html id on the rendered 'div' tag" do
          expect(output).to have_css('div#nav_id')
        end

        it "sets the right html classes on the rendered 'div' tag" do
          expect(output).to have_css('div.nav_class')
        end

        context 'when no item is selected' do
          it "doesn't render any 'a' tag in the 'div' tag" do
            expect(output).not_to have_css('div a')
          end
        end

        context 'when an item is selected' do
          let(:item) { :invoices }

          it "renders the selected 'a' tag" do
            expect(output).to have_css('div a')
          end

          it "remders the 'a' tag without any html id" do
            expect(output).not_to have_css('div a[id]')
          end

          it "renders the 'a' tag without any html class" do
            expect(output).not_to have_css('div a[class]')
          end

          context 'and the :allow_classes_and_ids option is true' do
            let(:options) {{ level: :all, allow_classes_and_ids: true }}

            it "renders the 'a' tag with the selected class" do
              expect(output).to have_css('div a.selected')
            end

            context "and the item hasn't any id explicitly set" do
              it "renders the 'a' tag without any html id" do
                expect(output).not_to have_css('div a[id]')
              end
            end

            context 'and the item has an explicitly set id' do
              let(:item) { :users }

              it "renders the 'a' tag with an html id" do
                expect(output).to have_css('div a#breadcrumb_users_link_id')
              end
            end
          end
        end

        context 'and the :prefix option is set' do
          let(:options) {{ prefix: 'You are here: ' }}

          context 'and there are no items to render' do
            let(:item) { nil }

            it "doesn't render the prefix before the breadcrumbs" do
              expect(raw_output).not_to match(/^<div.+>You are here: /)
            end
          end

          context 'and there are items to render' do
            let(:item) { :invoices }

            it 'renders the prefix before the breadcrumbs' do
              expect(raw_output).to match(/^<div.+>You are here: /)
            end
          end
        end

        context 'when a sub navigation item is selected' do
          before do
            allow(navigation[:invoices]).to receive_messages(selected?: true)

            allow(navigation[:invoices].sub_navigation[:unpaid]).to \
              receive_messages(selected?: true, selected_by_condition?: true)
          end

          it 'renders all items as links' do
            expect(output).to have_css('div a', 2)
          end

          context 'when the :static_leaf option is true' do
            let(:options) {{ level: :all, static_leaf: true }}

            it 'renders the items as links' do
              expect(output).to have_css('div a')
            end

            it 'renders the last item as simple text' do
              expect(output).to have_css('div span')
            end
          end
        end
      end
    end
  end
end
