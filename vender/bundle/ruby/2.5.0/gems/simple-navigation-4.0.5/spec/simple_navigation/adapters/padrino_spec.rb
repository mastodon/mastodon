module SimpleNavigation
  module Adapters
    describe Padrino do
      let(:adapter) { SimpleNavigation::Adapters::Padrino.new(context) }
      let(:content) { double(:content) }
      let(:context) { double(:context, request: request) }
      let(:request) { double(:request) }

      describe '#link_to' do
        it 'delegates to context' do
          expect(context).to receive(:link_to)
                             .with('name', 'url', :my_option => true)
          adapter.link_to('name', 'url', :my_option => true)
        end
      end

      describe '#content_tag' do
        it 'delegates to context' do
          expect(content).to receive(:html_safe).and_return('content')
          expect(context).to receive(:content_tag)
                             .with('type', 'content', my_option: true)
          adapter.content_tag('type', content, my_option: true)
        end
      end
    end
  end
end
