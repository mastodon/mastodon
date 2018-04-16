describe SimpleNavigation::Adapters::Sinatra do
  let(:adapter) { SimpleNavigation::Adapters::Sinatra.new(context) }
  let(:context) { double(:context) }
  let(:request) { double(:request, fullpath: '/full?param=true', path: '/full') }

  before { allow(context).to receive_messages(request: request) }

  describe '#context_for_eval' do
    context "when adapter's context is not set" do
      it 'raises an exception' do
        allow(adapter).to receive_messages(context: nil)
        expect{ adapter.context_for_eval }.to raise_error
      end
    end

    context "when adapter's context is set" do
      it 'returns the context' do
        expect(adapter.context_for_eval).to be context
      end
    end
  end

  describe '#request_uri' do
    it 'returns the request.fullpath' do
      expect(adapter.request_uri).to eq '/full?param=true'
    end
  end

  describe '#request_path' do
    it 'returns the request.path' do
      expect(adapter.request_path).to eq '/full'
    end
  end

  describe '#current_page?' do
    before { allow(request).to receive_messages(scheme: 'http', host_with_port: 'my_host:5000') }

    shared_examples 'detecting current page' do |url, expected|
      context "when url is #{url}" do
        it "returns #{expected}" do
          expect(adapter.current_page?(url)).to be expected
        end
      end
    end

    context 'when URL is not encoded' do
      it_behaves_like 'detecting current page', '/full?param=true', true
      it_behaves_like 'detecting current page', '/full?param3=true', false
      it_behaves_like 'detecting current page', '/full', true
      it_behaves_like 'detecting current page', 'http://my_host:5000/full?param=true', true
      it_behaves_like 'detecting current page', 'http://my_host:5000/full?param3=true', false
      it_behaves_like 'detecting current page', 'http://my_host:5000/full', true
      it_behaves_like 'detecting current page', 'https://my_host:5000/full', false
      it_behaves_like 'detecting current page', 'http://my_host:6000/full', false
      it_behaves_like 'detecting current page', 'http://my_other_host:5000/full', false
    end

    context 'when URL is encoded' do
      before do
        allow(request).to receive_messages(fullpath: '/full%20with%20spaces?param=true',
                     path: '/full%20with%20spaces')
      end

      it_behaves_like 'detecting current page', '/full%20with%20spaces?param=true', true
      it_behaves_like 'detecting current page', '/full%20with%20spaces?param3=true', false
      it_behaves_like 'detecting current page', '/full%20with%20spaces', true
      it_behaves_like 'detecting current page', 'http://my_host:5000/full%20with%20spaces?param=true', true
      it_behaves_like 'detecting current page', 'http://my_host:5000/full%20with%20spaces?param3=true', false
      it_behaves_like 'detecting current page', 'http://my_host:5000/full%20with%20spaces', true
      it_behaves_like 'detecting current page', 'https://my_host:5000/full%20with%20spaces', false
      it_behaves_like 'detecting current page', 'http://my_host:6000/full%20with%20spaces', false
      it_behaves_like 'detecting current page', 'http://my_other_host:5000/full%20with%20spaces', false
    end
  end

  describe '#link_to' do
    it 'returns a link with the correct class and id' do
      link = adapter.link_to('link', 'url', class: 'clazz', id: 'id')
      expect(link).to eq "<a href='url' class='clazz' id='id'>link</a>"
    end
  end

  describe '#content_tag' do
    it 'returns a tag with the correct class and id' do
      tag = adapter.content_tag(:div, 'content', class: 'clazz', id: 'id')
      expect(tag).to eq "<div class='clazz' id='id'>content</div>"
    end
  end
end
