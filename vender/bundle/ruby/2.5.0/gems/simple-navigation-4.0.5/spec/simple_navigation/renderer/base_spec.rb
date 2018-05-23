module SimpleNavigation
  module Renderer
    describe Base do
      subject(:base) { Base.new(options) }

      let(:adapter) { double(:adapter) }
      let(:options) { Hash.new }

      before { allow(SimpleNavigation).to receive_messages(adapter: adapter) }

      it 'delegates the :link_to method to adapter' do
        allow(adapter).to receive_messages(link_to: 'link_to')
        expect(base.link_to).to eq 'link_to'
      end

      it 'delegates the :content_tag method to adapter' do
        allow(adapter).to receive_messages(content_tag: 'content_tag')
        expect(base.content_tag).to eq 'content_tag'
      end

      describe '#initialize' do
        it "sets the renderer adapter to the SimpleNavigation one" do
          expect(base.adapter).to be adapter
        end
      end

      describe '#options' do
        it "returns the renderer's options" do
          expect(base.options).to be options
        end
      end

      describe '#render' do
        it "raise an exception to indicate it's a subclass responsibility" do
          expect{ base.render(:container) }.to raise_error
        end
      end

      describe '#expand_all?' do
        context 'when :options is set' do
          context 'and the :expand_all option is true' do
            let(:options) {{ expand_all: true }}

            it 'returns true' do
              expect(base.expand_all?).to be true
            end
          end

          context 'and the :expand_all option is false' do
            let(:options) {{ expand_all: false }}

            it 'returns false' do
              expect(base.expand_all?).to be false
            end
          end
        end

        context "when :options isn't set" do
          let(:options) { Hash.new }

          it 'returns false' do
            expect(base.expand_all?).to be false
          end
        end
      end

      describe '#skip_if_empty?' do
        context 'when :options is set' do
          context 'and the :skip_if_empty option is true' do
            let(:options) {{ skip_if_empty: true }}

            it 'returns true' do
              expect(base.skip_if_empty?).to be true
            end
          end

          context 'and the :skip_if_empty option is false' do
            let(:options) {{ skip_if_empty: false }}

            it 'returns true' do
              expect(base.skip_if_empty?).to be false
            end
          end
        end

        context "when :options isn't set" do
          let(:options) { Hash.new }

          it 'returns true' do
            expect(base.skip_if_empty?).to be false
          end
        end
      end

      describe '#level' do
        context 'and the :level option is set' do
          let(:options) {{ level: 1 }}

          it 'returns the specified level' do
            expect(base.level).to eq 1
          end
        end

        context "and the :level option isn't set" do
          let(:options) { Hash.new }

          it 'returns :all' do
            expect(base.level).to eq :all
          end
        end
      end

      describe '#consider_sub_navigation?' do
        let(:item) { double(:item) }

        before { allow(item).to receive_messages(sub_navigation: sub_navigation) }

        context 'when the item has no sub navigation' do
          let(:sub_navigation) { nil }

          it 'returns false' do
            expect(base.send(:consider_sub_navigation?, item)).to be false
          end
        end

        context 'when the item has sub navigation' do
          let(:sub_navigation) { double(:sub_navigation) }

          context 'and the renderer has an unknown level' do
            before { allow(base).to receive_messages(level: 'unknown') }

            it 'returns false' do
              expect(base.send(:consider_sub_navigation?, item)).to be false
            end
          end

          context 'and the renderer has a level set to :all' do
            before { allow(base).to receive_messages(level: :all) }

            it 'returns false' do
              expect(base.send(:consider_sub_navigation?, item)).to be true
            end
          end

          context "when the renderer's level is a number" do
            before { allow(base).to receive_messages(level: 2) }

            it 'returns false' do
              expect(base.send(:consider_sub_navigation?, item)).to be false
            end
          end

          context "when the renderer's level is a Range" do
            before { allow(base).to receive_messages(level: 2..3) }

            context "and sub navigation's level is greater than range.max" do
              before { allow(sub_navigation).to receive_messages(level: 4) }

              it 'returns false' do
                expect(base.send(:consider_sub_navigation?, item)).to be false
              end
            end

            context "and sub navigation's level is equal to range.max" do
              before { allow(sub_navigation).to receive_messages(level: 3) }

              it 'returns true' do
                expect(base.send(:consider_sub_navigation?, item)).to be true
              end
            end

            context "and sub navigation's level is equal to range.min" do
              before { allow(sub_navigation).to receive_messages(level: 2) }

              it 'returns true' do
                expect(base.send(:consider_sub_navigation?, item)).to be true
              end
            end
          end
        end
      end

      describe '#include_sub_navigation?' do
        let(:item) { double(:item) }

        context 'when consider_sub_navigation? is true' do
          before { allow(base).to receive_messages(consider_sub_navigation?: true) }

          context 'and expand_sub_navigation? is true' do
            before { allow(base).to receive_messages(expand_sub_navigation?: true) }

            it 'returns true' do
              expect(base.include_sub_navigation?(item)).to be true
            end
          end

          context 'and expand_sub_navigation? is false' do
            before { allow(base).to receive_messages(expand_sub_navigation?: false) }

            it 'returns false' do
              expect(base.include_sub_navigation?(item)).to be false
            end
          end
        end

        context 'consider_sub_navigation? is false' do
          before { allow(base).to receive_messages(consider_sub_navigation?: false) }

          context 'and expand_sub_navigation? is true' do
            before { allow(base).to receive_messages(expand_sub_navigation?: true) }

            it 'returns false' do
              expect(base.include_sub_navigation?(item)).to be false
            end
          end

          context 'and expand_sub_navigation? is false' do
            before { allow(base).to receive_messages(expand_sub_navigation?: false) }

            it 'returns false' do
              expect(base.include_sub_navigation?(item)).to be false
            end
          end
        end
      end

      describe '#render_sub_navigation_for' do
        let(:item) { double(:item, sub_navigation: sub_navigation) }
        let(:sub_navigation) { double(:sub_navigation) }

        it 'renders the sub navigation passing it the options' do
          expect(sub_navigation).to receive(:render).with(options)
          base.render_sub_navigation_for(item)
        end
      end
    end
  end
end
