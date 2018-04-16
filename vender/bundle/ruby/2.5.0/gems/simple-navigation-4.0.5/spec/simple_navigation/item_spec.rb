module SimpleNavigation
  describe Item do
    let!(:item_container) { ItemContainer.new }

    let(:adapter) { double(:adapter) }
    let(:item_args) { [item_container, :my_key, 'name', url, options] }
    let(:item) { Item.new(*item_args) }
    let(:options) { Hash.new }
    let(:url) { 'url' }

    before { allow(SimpleNavigation).to receive_messages(adapter: adapter) }

    describe '#highlights_on' do
      let(:options) {{ highlights_on: :test }}

      it "returns the item's highlights_on option" do
        expect(item.highlights_on).to eq :test
      end
    end

    describe '#initialize' do
      context 'when there is a sub_navigation' do
        let(:subnav_container) { double(:subnav_container).as_null_object }

        shared_examples 'creating sub navigation container' do
          it 'creates a sub navigation container with a level+1' do
            expect(item.sub_navigation.level).to eq 2
          end
        end

        context 'when a block is given' do
          it_behaves_like 'creating sub navigation container' do
            let(:item) { Item.new(*item_args) {} }
          end

          it 'calls the block' do
            allow(ItemContainer).to receive_messages(new: subnav_container)

            expect{ |blk|
              Item.new(*item_args, &blk)
            }.to yield_with_args(subnav_container)
          end
        end

        context 'when no block is given' do
          context 'and items are given' do
            let(:items) { [] }
            let(:options) {{ items: items }}

            it_behaves_like 'creating sub navigation container'

            it "sets the items on the subnav_container" do
              expect(item.sub_navigation.items).to eq items
            end
          end

          context 'and no items are given' do
            it "doesn't create a new ItemContainer" do
              item = Item.new(*item_args)
              expect(item.sub_navigation).to be_nil
            end
          end
        end
      end

      context 'when a :method option is given' do
        let(:options) {{ method: :delete }}

        it "sets the item's method" do
          expect(item.method).to eq :delete
        end
      end

      context 'when no :method option is given' do
        it "sets the item's method to nil" do
          expect(item.method).to be_nil
        end
      end

      context 'when an :highlights_on option is given' do
        let(:highlights_on) { double(:highlights_on) }
        let(:options) {{ highlights_on: highlights_on }}

        it "sets the item's highlights_on" do
          expect(item.highlights_on).to eq highlights_on
        end
      end

      context 'when no :highlights_on option is given' do
        it "sets the item's highlights_on to nil" do
          expect(item.highlights_on).to be_nil
        end
      end

      context 'when a url is given' do
        context 'and it is a string' do
          it "sets the item's url accordingly" do
            expect(item.url).to eq 'url'
          end
        end

        context 'and it is a proc' do
          let(:url) { proc{ "my_" + "url" } }

          it "sets the item's url accordingly" do
            expect(item.url).to eq 'my_url'
          end
        end

        context 'and it is nil' do
          let(:url) { nil }

          it "sets the item's url accordingly" do
            expect(item.url).to be_nil
          end
        end
      end

      context 'when no url nor options is specified' do
        let(:item_args) { [item_container, :my_key, 'name'] }

        it "sets the item's url to nil" do
          expect(item.url).to be_nil
        end
      end

      context 'when only a url is given' do
        let(:item_args) { [item_container, :my_key, 'name', 'url'] }

        it "set the item's url accordingly" do
          expect(item.url).to eq 'url'
        end
      end

      context 'when url and options are given' do
        let(:options) {{ html: { option: true } }}

        before { allow(adapter).to receive_messages(current_page?: false) }

        it "set the item's url accordingly" do
          expect(item.url).to eq 'url'
        end

        it "sets the item's html_options accordingly" do
          allow(item).to \
            receive_messages(selected_by_subnav?: false,
                             selected_by_condition?: false)
          expect(item.html_options).to include(option: true)
        end
      end
    end

    describe '#link_html_options' do
      let(:options) {{ link_html: :test }}

      it "returns the item's link_html option" do
        expect(item.link_html_options).to eq :test
      end
    end

    describe '#method' do
      let(:options) {{ method: :test }}

      it "returns the item's method option" do
        expect(item.method).to eq :test
      end
    end

    describe '#name' do
      before do
        allow(SimpleNavigation.config).to \
          receive_messages(name_generator: proc{ |name| "<span>#{name}</span>" })
      end

      context 'when no option is given' do
        context 'and the name_generator uses only the name' do
          it 'uses the default name_generator' do
            expect(item.name).to eq '<span>name</span>'
          end
        end

        context 'and the name_generator uses only the item itself' do
          before do
            allow(SimpleNavigation.config).to \
              receive_messages(name_generator: proc{ |name, item| "<span>#{item.key}</span>" })
          end

          it 'uses the default name_generator' do
            expect(item.name).to eq '<span>my_key</span>'
          end
        end
      end

      context 'when the :apply_generator is false' do
        it "returns the item's name" do
          expect(item.name(apply_generator: false)).to eq 'name'
        end
      end

      context 'when a block is given' do
        let(:item_args) { [item_container, :my_key, -> { 'Name in block' }, url, options] }

        it "returns the item's name that is defined in the block" do
          expect(item.name).to include 'Name in block'
        end
      end
    end

    describe '#selected?' do
      context 'when the item has no :highlights_on option' do
        before { allow(SimpleNavigation).to receive_messages(config: config) }

        context 'and auto highlighting is off' do
          let(:config) { double(:config, auto_highlight: false) }

          it 'returns false' do
            expect(item.selected?).to be false
          end
        end

        context 'and auto highlighting is on' do
          let(:config) { double(:config, ignore_query_params_on_auto_highlight: true, ignore_anchors_on_auto_highlight: true, auto_highlight: true) }

          context "and the current url matches the item's url" do
            before { allow(adapter).to receive_messages(current_page?: true) }

            it 'returns true' do
              expect(item.selected?).to be true
            end
          end

          context "and the current url does not match the item's url" do
            let(:config) do
              double(:config, auto_highlight: false, highlight_on_subpath: false)
            end

            before { allow(adapter).to receive_messages(current_page?: false) }

            it 'returns false' do
              expect(item.selected?).to be false
            end
          end

          context 'and highlights_on_subpath is on' do
            let(:config) do
              double(:config, auto_highlight: true, highlight_on_subpath: true, ignore_query_params_on_auto_highlight: true, ignore_anchors_on_auto_highlight: true)
            end

            context "but item has no url" do
              let(:url) { nil }

              it 'returns false' do
                expect(item.selected?).to be false
              end
            end

            context "and the current url is a sub path of the item's url" do
              before do
                allow(adapter).to \
                  receive_messages(current_page?: false, request_uri: 'url/test')
              end

              it 'returns true' do
                expect(item.selected?).to be true
              end
            end

            context "and the current url is not a sub path of the item's url" do
              before do
                allow(adapter).to \
                  receive_messages(current_page?: false, request_uri: 'other/test')
              end

              it 'returns false' do
                expect(item.selected?).to be false
              end
            end
          end
        end
      end

      context 'when the item has a :highlights_on option' do
        context 'and it is a regular expression' do
          before { allow(adapter).to receive_messages(request_uri: '/test') }

          context 'and the current url matches the expression' do
            let(:options) {{ highlights_on: /test/ }}

            it 'returns true' do
              expect(item.selected?).to be true
            end
          end

          context 'and the current url does not match the expression' do
            let(:options) {{ highlights_on: /other/ }}

            it 'returns false' do
              expect(item.selected?).to be false
            end
          end
        end

        context 'and it is a callable object' do
          context 'and the call returns true' do
            let(:options) {{ highlights_on: -> { true } }}

            it 'returns true' do
              expect(item.selected?).to be true
            end
          end

          context 'and the call returns false' do
            let(:options) {{ highlights_on: -> { false } }}

            it 'returns false' do
              expect(item.selected?).to be false
            end
          end
        end

        context 'and it is the :subpath symbol' do
          let(:options) {{ highlights_on: :subpath }}

          context "and the current url is a sub path of the item's url" do
            before do
              allow(adapter).to receive_messages(request_uri: 'url/test')
            end

            it 'returns true' do
              expect(item.selected?).to be true
            end
          end

          context "and the current url is not a sub path of the item's url" do
            before do
              allow(adapter).to receive_messages(request_uri: 'other/test')
            end

            it 'returns false' do
              expect(item.selected?).to be false
            end
          end
        end

        context 'and it is non usable' do
          let(:options) {{ highlights_on: :hello }}

          it 'raises an exception' do
            expect{ item.selected? }.to raise_error
          end
        end
      end
    end

    describe '#selected_class' do
      context 'when the item is selected' do
        before { allow(item).to receive_messages(selected?: true) }

        it 'returns the default selected_class' do
          expect(item.selected_class).to eq 'selected'
        end

        context 'and selected_class is defined in the context' do
          before { allow(item_container).to receive_messages(selected_class: 'defined') }

          it "returns the context's selected_class" do
            expect(item.selected_class).to eq 'defined'
          end
        end
      end

      context 'when the item is not selected' do
        before { allow(item).to receive_messages(selected?: false) }

        it 'returns nil' do
          expect(item.selected_class).to be_nil
        end
      end
    end

    describe ':html_options argument' do
      let(:selected_classes) { 'selected simple-navigation-active-leaf' }

      context 'when the :class option is given' do
        let(:options) {{ html: { class: 'my_class' } }}

        context 'and the item is selected' do
          before { allow(item).to receive_messages(selected?: true, selected_by_condition?: true) }

          it "adds the specified class to the item's html classes" do
            expect(item.html_options[:class]).to include('my_class')
          end

          it "doesn't replace the default html classes of a selected item" do
            expect(item.html_options[:class]).to include(selected_classes)
          end
        end

        context "and the item isn't selected" do
          before { allow(item).to receive_messages(selected?: false, selected_by_condition?: false) }

          it "sets the specified class as the item's html classes" do
            expect(item.html_options[:class]).to include('my_class')
          end
        end
      end

      context "when the :class option isn't given" do
        context 'and the item is selected' do
          before { allow(item).to receive_messages(selected?: true, selected_by_condition?: true) }

          it "sets the default html classes of a selected item" do
            expect(item.html_options[:class]).to include(selected_classes)
          end
        end

        context "and the item isn't selected" do
           before { allow(item).to receive_messages(selected?: false, selected_by_condition?: false) }

           it "doesn't set any html class on the item" do
             expect(item.html_options[:class]).to be_blank
           end
        end
      end

      shared_examples 'generating id' do |id|
        it "sets the item's html id to the specified id" do
          expect(item.html_options[:id]).to eq id
        end
      end

      describe 'when the :id option is given' do
        let(:options) {{ html: { id: 'my_id' } }}

        before do
          allow(SimpleNavigation.config).to receive_messages(autogenerate_item_ids: generate_ids)
          allow(item).to receive_messages(selected?: false, selected_by_condition?: false)
        end

        context 'and :autogenerate_item_ids is true' do
          let(:generate_ids) { true }

          it_behaves_like 'generating id', 'my_id'
        end

        context 'and :autogenerate_item_ids is false' do
          let(:generate_ids) { false }

          it_behaves_like 'generating id', 'my_id'
        end
      end

      context "when the :id option isn't given" do
        before do
          allow(SimpleNavigation.config).to receive_messages(autogenerate_item_ids: generate_ids)
          allow(item).to receive_messages(selected?: false, selected_by_condition?: false)
        end

        context 'and :autogenerate_item_ids is true' do
          let(:generate_ids) { true }

          it_behaves_like 'generating id', 'my_key'
        end

        context 'and :autogenerate_item_ids is false' do
          let(:generate_ids) { false }

          it "doesn't set any html id on the item" do
            expect(item.html_options[:id]).to be_blank
          end
        end
      end
    end
  end
end
