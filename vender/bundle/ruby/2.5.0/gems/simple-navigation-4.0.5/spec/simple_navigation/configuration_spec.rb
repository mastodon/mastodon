module SimpleNavigation
  describe Configuration do
    subject(:config) { Configuration.instance }

    describe '.run' do
      it "yields the singleton Configuration object" do
        expect{ |blk| Configuration.run(&blk) }.to yield_with_args(config)
      end
    end

    describe '.eval_config' do
      let(:config_files) {{ default: 'default', my_context: 'my_context' }}
      let(:eval_context) { double(:eval_context) }

      before do
        allow(eval_context).to receive(:instance_eval)
        allow(SimpleNavigation).to \
          receive_messages(context_for_eval: eval_context, config_files: config_files)
      end

      context "with default navigation context" do
        it "calls instance_eval with the default config_file-string inside the context" do
          expect(eval_context).to receive(:instance_eval).with('default')
          Configuration.eval_config
        end
      end

      context 'with non default navigation context' do
        it "calls instance_eval with the specified config_file-string inside the context" do
          expect(eval_context).to receive(:instance_eval).with('my_context')
          Configuration.eval_config(:my_context)
        end
      end
    end

    describe '#initialize' do
      it 'sets the List-Renderer as default' do
        expect(config.renderer).to be Renderer::List
      end

      it 'sets the selected_class to "selected" as default' do
        expect(config.selected_class).to eq 'selected'
      end

      it 'sets the active_leaf_class to "simple-navigation-active-leaf" as default' do
        expect(config.active_leaf_class).to eq 'simple-navigation-active-leaf'
      end

      it 'sets autogenerate_item_ids to true as default' do
        expect(config.autogenerate_item_ids).to be true
      end

      it 'sets auto_highlight to true as default' do
        expect(config.auto_highlight).to be true
      end

      it 'sets the id_generator to a callable object' do
        expect(config.id_generator).to respond_to(:call)
      end

      it 'sets the name_generator to a callable object' do
        expect(config.name_generator).to respond_to(:call)
      end

      it 'sets the consider_item_names_as_safe to false' do
        expect(config.consider_item_names_as_safe).to be false
      end

      it 'sets highlights_on_subpath to false as default' do
        expect(config.highlight_on_subpath).to be false
      end
      
      it 'sets ignore_query_params_on_auto_highlight to true as default' do
        expect(config.ignore_query_params_on_auto_highlight).to be true
      end

      it 'sets ignore_anchors_on_auto_highlight to true as default' do
        expect(config.ignore_anchors_on_auto_highlight).to be true
      end
    end

    describe '#items' do
      let(:container) { double(:items_container) }

      before { allow(ItemContainer).to receive_messages(new: container) }

      context 'when a block is given' do
        context 'and items_provider is specified' do
          let(:provider) { double(:provider) }

          it 'raises an exception' do
            expect{ config.items(provider) {} }.to raise_error
          end
        end

        context 'when no items_provider is specified' do
          it 'yields an new ItemContainer' do
            expect{ |blk| config.items(&blk) }.to yield_with_args(container)
          end

          it 'assigns the ItemContainer to an instance-var' do
            config.items {}
            expect(config.primary_navigation).to be container
          end

          it "doesn't set the items on the container" do
            expect(container).not_to receive(:items=)
            config.items {}
          end
        end
      end

      context 'when no block is given' do
        context 'and items_provider is specified' do
          let(:external_provider) { double(:external_provider) }
          let(:items) { double(:items) }
          let(:items_provider) { double(:items_provider, items: items) }

          before do
            allow(SimpleNavigation::ItemsProvider).to receive_messages(new: items_provider)
            allow(container).to receive(:items=)
          end

          it 'creates a new Provider object for the specified provider' do
            expect(ItemsProvider).to receive(:new).with(external_provider)
            config.items(external_provider)
          end

          it 'calls items on the provider object' do
            expect(items_provider).to receive(:items)
            config.items(external_provider)
          end

          it 'sets the items on the container' do
            expect(container).to receive(:items=).with(items)
            config.items(external_provider)
          end
        end

        context 'when items_provider is not specified' do
          it "raises an exception" do
            expect{ config.items }.to raise_error
          end
        end
      end
    end

    describe '#loaded?' do
      context 'when primary_nav is set' do
        it 'returns true' do
          config.instance_variable_set(:@primary_navigation, :bla)
          expect(config).to be_loaded
        end
      end

      context 'when primary_nav is not set' do
        it 'returns false if no primary_nav is set' do
          config.instance_variable_set(:@primary_navigation, nil)
          expect(config).not_to be_loaded
        end
      end
    end
  end
end
