module SimpleNavigation
  describe Helpers do
    subject(:controller) { test_controller_class.new }

    let(:invoices_item) { navigation[:invoices] }
    let(:item) { nil }
    let(:navigation) { setup_navigation('nav_id', 'nav_class') }
    let(:test_controller_class) do
      Class.new { include SimpleNavigation::Helpers }
    end
    let(:unpaid_item) { invoices_item.sub_navigation[:unpaid] }

    before do
      allow(Configuration).to receive(:eval_config)
      allow(SimpleNavigation).to receive_messages(load_config: nil,
                            primary_navigation: navigation,
                            config_file?: true,
                            context_for_eval: controller)

      select_an_item(navigation[item]) if item
    end

    describe '#active_navigation_item_name' do
      context 'when no item is selected' do
        it 'returns an empty string for no parameters' do
          expect(controller.active_navigation_item_name).to eq ''
        end

        it "returns an empty string for level: 1" do
          item_name = controller.active_navigation_item_name(level: 1)
          expect(item_name).to eq ''
        end

        it 'returns an empty string for level: 2' do
          item_name = controller.active_navigation_item_name(level: 2)
          expect(item_name).to eq ''
        end

        it 'returns an empty string for level: :all' do
          item_name = controller.active_navigation_item_name(level: :all)
          expect(item_name).to eq ''
        end
      end

      context 'when an item is selected' do
        context "and it's a primary item" do
          let(:item) { :invoices }

          it 'returns an empty string' do
            expect(controller.active_navigation_item_name).to eq ''
          end

          it "returns the selected item's name for level: 1" do
            item_name = controller.active_navigation_item_name(level: 1)
            expect(item_name).to eq 'Invoices'
          end

          it 'returns an empty string for level: 2' do
            item_name = controller.active_navigation_item_name(level: 2)
            expect(item_name).to eq ''
          end

          it 'returns an empty string for level: :all' do
            item_name = controller.active_navigation_item_name(level: :all)
            expect(item_name).to eq ''
          end
        end

        context "and it's a sub navigation item" do
          before do
            select_an_item(invoices_item)
            select_an_item(unpaid_item)
          end

          it "returns the selected item's name" do
            expect(controller.active_navigation_item_name).to eq 'Unpaid'
          end

          it "returns the selected item's parent name for level: 1" do
            item_name = controller.active_navigation_item_name(level: 1)
            expect(item_name).to eq 'Invoices'
          end

          it "returns the selected item's name for level: 2" do
            item_name = controller.active_navigation_item_name(level: 2)
            expect(item_name).to eq 'Unpaid'
          end

          it "returns the selected item's name for level: :all" do
            item_name = controller.active_navigation_item_name(level: :all)
            expect(item_name).to eq 'Unpaid'
          end
        end
      end
    end

    describe '#active_navigation_item_key' do
      context 'when no item is selected' do
        it 'returns nil' do
          expect(controller.active_navigation_item_key).to be_nil
        end

        it 'returns nil for no parameters' do
          expect(controller.active_navigation_item_key).to be_nil
        end

        it "returns nil for level: 1" do
          item_key = controller.active_navigation_item_key(level: 1)
          expect(item_key).to be_nil
        end

        it 'returns nil for level: 2' do
          item_key = controller.active_navigation_item_key(level: 2)
          expect(item_key).to be_nil
        end

        it 'returns nil for level: :all' do
          item_key = controller.active_navigation_item_key(level: :all)
          expect(item_key).to be_nil
        end
      end

      context 'when an item is selected' do
        context "and it's a primary item" do
          let(:item) { :invoices }

          it 'returns nil for no parameters' do
            expect(controller.active_navigation_item_key).to be_nil
          end

          it "returns the selected item's name for level: 1" do
            item_key = controller.active_navigation_item_key(level: 1)
            expect(item_key).to eq :invoices
          end

          it 'returns nil for level: 2' do
            item_key = controller.active_navigation_item_key(level: 2)
            expect(item_key).to be_nil
          end

          it 'returns nil for level: :all' do
            item_key = controller.active_navigation_item_key(level: :all)
            expect(item_key).to be_nil
          end
        end

        context "and it's a sub navigation item" do
          before do
            select_an_item(invoices_item)
            select_an_item(unpaid_item)
          end

          it "returns the selected item's name" do
            expect(controller.active_navigation_item_key).to eq :unpaid
          end

          it "returns the selected item's parent name for level: 1" do
            item_key = controller.active_navigation_item_key(level: 1)
            expect(item_key).to eq :invoices
          end

          it "returns the selected item's name for level: 2" do
            item_key = controller.active_navigation_item_key(level: 2)
            expect(item_key).to eq :unpaid
          end

          it "returns the selected item's name for level: :all" do
            item_key = controller.active_navigation_item_key(level: :all)
            expect(item_key).to eq :unpaid
          end
        end
      end
    end

    describe '#active_navigation_item' do
      context 'when no item is selected' do
        it 'returns nil for no parameters' do
          expect(controller.active_navigation_item).to be_nil
        end

        it "returns nil for level: 1" do
          item_key = controller.active_navigation_item(level: 1)
          expect(item_key).to be_nil
        end

        it 'returns nil for level: 2' do
          item_key = controller.active_navigation_item(level: 2)
          expect(item_key).to be_nil
        end

        it 'returns nil for level: :all' do
          item_key = controller.active_navigation_item(level: :all)
          expect(item_key).to be_nil
        end
      end

      context 'when an item is selected' do
        context "and it's a primary item" do
          let(:item) { :invoices }

          it 'returns nil for no parameters' do
            expect(controller.active_navigation_item).to be_nil
          end

          it "returns the selected item's name for level: 1" do
            item_key = controller.active_navigation_item(level: 1)
            expect(item_key).to be invoices_item
          end

          it 'returns nil for level: 2' do
            item_key = controller.active_navigation_item(level: 2)
            expect(item_key).to be_nil
          end

          it 'returns nil for level: :all' do
            item_key = controller.active_navigation_item(level: :all)
            expect(item_key).to be_nil
          end
        end

        context "and it's a sub navigation item" do
          before do
            select_an_item(invoices_item)
            select_an_item(unpaid_item)
          end

          it "returns the selected item's name for no parameters" do
            expect(controller.active_navigation_item).to be unpaid_item
          end

          it "returns the selected item's parent name for level: 1" do
            item_key = controller.active_navigation_item(level: 1)
            expect(item_key).to be invoices_item
          end

          it "returns the selected item's name for level: 2" do
            item_key = controller.active_navigation_item(level: 2)
            expect(item_key).to eq unpaid_item
          end

          it "returns the selected item's name for level: :all" do
            item_key = controller.active_navigation_item(level: :all)
            expect(item_key).to eq unpaid_item
          end
        end
      end
    end

    describe '#active_navigation_item_container' do
      shared_examples 'returning items container' do
        it 'returns the primary navigation for no parameters' do
          expect(controller.active_navigation_item_container).to be navigation
        end

        it "returns the primary navigation for level: 1" do
          item_container = controller.active_navigation_item_container(level: 1)
          expect(item_container).to be navigation
        end

        it 'returns the primary navigation level: :all' do
          item_container =
            controller.active_navigation_item_container(level: :all)
          expect(item_container).to be navigation
        end
      end

      context 'when no item is selected' do
        it_behaves_like 'returning items container'

        it 'returns nil for level: 2' do
          item_container = controller.active_navigation_item_container(level: 2)
          expect(item_container).to be_nil
        end
      end

      context 'when an item is selected' do
        context "and it's a primary item" do
          let(:item) { :invoices }

          it_behaves_like 'returning items container'

          it 'returns the invoices items container for level: 2' do
            item_container =
              controller.active_navigation_item_container(level: 2)
            expect(item_container).to be invoices_item.sub_navigation
          end
        end

        context "and it's a sub navigation item" do
          before do
            select_an_item(invoices_item)
            select_an_item(unpaid_item)
          end

          it_behaves_like 'returning items container'

          it 'returns the invoices items container for level: 2' do
            item_container =
              controller.active_navigation_item_container(level: 2)
            expect(item_container).to be invoices_item.sub_navigation
          end
        end
      end
    end

    describe '#render_navigation' do
      it 'evaluates the configuration on every request' do
        expect(SimpleNavigation).to receive(:load_config).twice
        2.times { controller.render_navigation }
      end

      it 'loads the :default configuration' do
        expect(SimpleNavigation).to receive(:load_config).with(:default)
        controller.render_navigation
      end

      it "doesn't set the items directly" do
        expect(SimpleNavigation.config).not_to receive(:items)
        controller.render_navigation
      end

      it 'looks up the active_item_container based on the level' do
        expect(SimpleNavigation).to receive(:active_item_container_for)
                                    .with(:all)
        controller.render_navigation
      end

      context 'when the :context option is specified' do
        it 'loads the configuration for the specified context' do
          expect(SimpleNavigation).to receive(:load_config).with(:my_context)
          controller.render_navigation(context: :my_context)
        end
      end

      context 'when the :items option is specified' do
        let(:items) { double(:items) }

        it 'sets the items directly' do
          expect(SimpleNavigation.config).to receive(:items).with(items)
          controller.render_navigation(items: items)
        end
      end

      context 'when the :level option is set' do
        context 'and its value is 1' do
          it 'calls render on the primary navigation' do
            expect(navigation).to receive(:render).with(level: 1)
            controller.render_navigation(level: 1)
          end
        end

        context 'and its value is 2' do
          context 'and the active_item_container is set' do
            let(:item_container) { double(:container).as_null_object }

            before do
              allow(SimpleNavigation).to receive_messages(active_item_container_for: item_container)
            end

            it 'finds the selected sub navigation for the specified level' do
              expect(SimpleNavigation).to receive(:active_item_container_for)
                                            .with(2)
              controller.render_navigation(level: 2)
            end

            it 'calls render on the active item_container' do
              expect(item_container).to receive(:render).with(level: 2)
              controller.render_navigation(level: 2)
            end
          end

          context "and the active_item_container isn't set" do
            it "doesn't raise an exception" do
              expect{
                controller.render_navigation(level: 2)
              }.not_to raise_error
            end
          end
        end

        context "and its value isn't a valid level" do
          it 'raises an exception' do
            expect{
              controller.render_navigation(level: :invalid)
            }.to raise_error
          end
        end
      end

      context 'when the :levels option is set' do
        before { allow(SimpleNavigation).to receive_messages(active_item_container_for: navigation) }

        it 'treats it like the :level option' do
          expect(navigation).to receive(:render).with(level: 2)
          controller.render_navigation(levels: 2)
        end
      end

      context 'when a block is given' do
        it 'calls the block passing it an item container' do
          expect{ |blk|
            controller.render_navigation(&blk)
          }.to yield_with_args(ItemContainer)
        end
      end

      context 'when no primary configuration is defined' do
        before { allow(SimpleNavigation).to receive_messages(primary_navigation: nil) }

        it 'raises an exception' do
          expect{controller.render_navigation}.to raise_error
        end
      end

      context "when active_item_container is set" do
        let(:active_item_container) { double(:container).as_null_object }

        before do
          allow(SimpleNavigation).to receive_messages(active_item_container_for: active_item_container)
        end

        it 'calls render on the active_item_container' do
          expect(active_item_container).to receive(:render)
          controller.render_navigation
        end
      end
    end
  end
end
