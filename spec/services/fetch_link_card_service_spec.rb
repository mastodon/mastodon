require 'rails_helper'

RSpec.describe FetchLinkCardService do
  subject { FetchLinkCardService.new }

  before do
    stub_request(:head, 'http://example.xn--fiqs8s/').to_return(status: 200, headers: { 'Content-Type' => 'text/html' })
    stub_request(:get, 'http://example.xn--fiqs8s/').to_return(request_fixture('idn.txt'))
    stub_request(:head, 'http://example.com/sjis').to_return(status: 200, headers: { 'Content-Type' => 'text/html' })
    stub_request(:get, 'http://example.com/sjis').to_return(request_fixture('sjis.txt'))
    stub_request(:head, 'http://example.com/sjis_with_wrong_charset').to_return(status: 200, headers: { 'Content-Type' => 'text/html' })
    stub_request(:get, 'http://example.com/sjis_with_wrong_charset').to_return(request_fixture('sjis_with_wrong_charset.txt'))
    stub_request(:head, 'http://example.com/koi8-r').to_return(status: 200, headers: { 'Content-Type' => 'text/html' })
    stub_request(:get, 'http://example.com/koi8-r').to_return(request_fixture('koi8-r.txt'))
    stub_request(:head, 'https://github.com/qbi/WannaCry').to_return(status: 404)

    subject.call(status)
  end

  context 'in a local status' do
    context do
      let(:status) { Fabricate(:status, text: 'Check out http://example.中国') }

      it 'works with IDN URLs' do
        expect(a_request(:get, 'http://example.xn--fiqs8s/')).to have_been_made.at_least_once
      end
    end

    context do
      let(:status) { Fabricate(:status, text: 'Check out http://example.com/sjis') }

      it 'works with SJIS' do
        expect(a_request(:get, 'http://example.com/sjis')).to have_been_made.at_least_once
        expect(status.preview_card.title).to eq("SJISのページ")
      end
    end

    context do
      let(:status) { Fabricate(:status, text: 'Check out http://example.com/sjis_with_wrong_charset') }

      it 'works with SJIS even with wrong charset header' do
        expect(a_request(:get, 'http://example.com/sjis_with_wrong_charset')).to have_been_made.at_least_once
        expect(status.preview_card.title).to eq("SJISのページ")
      end
    end

    context do
      let(:status) { Fabricate(:status, text: 'Check out http://example.com/koi8-r') }

      it 'works with koi8-r' do
        expect(a_request(:get, 'http://example.com/koi8-r')).to have_been_made.at_least_once
        expect(status.preview_card.title).to eq("Московя начинаетъ только въ XVI ст. привлекать внимане иностранцевъ.")
      end
    end
  end

  context 'in a remote status' do
    let(:status) { Fabricate(:status, uri: 'abc', text: 'Habt ihr ein paar gute Links zu #<span class="tag"><a href="https://quitter.se/tag/wannacry" target="_blank" rel="tag noopener" title="https://quitter.se/tag/wannacry">Wannacry</a></span> herumfliegen?   Ich will mal unter <br> <a href="https://github.com/qbi/WannaCry" target="_blank" rel="noopener" title="https://github.com/qbi/WannaCry">https://github.com/qbi/WannaCry</a> was sammeln. !<a href="http://sn.jonkman.ca/group/416/id" target="_blank" rel="noopener" title="http://sn.jonkman.ca/group/416/id">security</a>&nbsp;') }

    it 'parses out URLs' do
      expect(a_request(:head, 'https://github.com/qbi/WannaCry')).to have_been_made.at_least_once
    end

    it 'ignores URLs to hashtags' do
      expect(a_request(:head, 'https://quitter.se/tag/wannacry')).to_not have_been_made
    end
  end
end
