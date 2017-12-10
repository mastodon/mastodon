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
    stub_request(:head, 'http://example.com/日本語').to_return(status: 200, headers: { 'Content-Type' => 'text/html' })
    stub_request(:get, 'http://example.com/日本語').to_return(request_fixture('sjis.txt'))
    stub_request(:head, 'https://github.com/qbi/WannaCry').to_return(status: 404)
  end

  context 'in a local status' do
    context do
      let(:status) { Fabricate(:status, text: 'Check out http://example.中国') }

      it 'works with IDN URLs' do
        subject.call(status)
        expect(a_request(:get, 'http://example.xn--fiqs8s/')).to have_been_made.at_least_once
      end
    end

    context do
      let(:status) { Fabricate(:status, text: 'Check out http://example.com/sjis') }

      it 'works with SJIS' do
        subject.call(status)

        expect(a_request(:get, 'http://example.com/sjis')).to have_been_made.at_least_once
        expect(status.preview_cards.first.title).to eq("SJISのページ")
      end
    end

    context do
      let(:status) { Fabricate(:status, text: 'Check out http://example.com/sjis_with_wrong_charset') }

      it 'works with SJIS even with wrong charset header' do
        subject.call(status)

        expect(a_request(:get, 'http://example.com/sjis_with_wrong_charset')).to have_been_made.at_least_once
        expect(status.preview_cards.first.title).to eq("SJISのページ")
      end
    end

    context do
      let(:status) { Fabricate(:status, text: 'Check out http://example.com/koi8-r') }

      it 'works with koi8-r' do
        subject.call(status)

        expect(a_request(:get, 'http://example.com/koi8-r')).to have_been_made.at_least_once
        expect(status.preview_cards.first.title).to eq("Московя начинаетъ только въ XVI ст. привлекать внимане иностранцевъ.")
      end
    end

    context do
      let(:status) { Fabricate(:status, text: 'テストhttp://example.com/日本語') }

      it 'works with Japanese path string' do
        subject.call(status)

        expect(a_request(:get, 'http://example.com/日本語')).to have_been_made.at_least_once
        expect(status.preview_cards.first.title).to eq("SJISのページ")
      end
    end

    context 'when preview card distribution is queued' do
      let(:status) { Fabricate(:status, id: 1) }

      before { Redis.current.sadd 'preview_card_fetch:1:queue', status.id }

      it 'distributes preview card' do
        new = FanOutPreviewCardOnWriteService.method(:new)
        expect(FanOutPreviewCardOnWriteService).to receive(:new) do |*args|
          expect(args).to be_empty

          instance = new.call
          expect(instance).to receive(:call).with(status)
          instance
        end

        subject.call(status)
      end

      it 'deletes preview card queue after fetching' do
        subject.call(status)
        expect(Redis.current.exists('preview_card:1:queue')).to eq false
      end
    end

    it 'deletes preview card fetch flag after fetching' do
      status = Fabricate(:status, id: 1)
      Redis.current.set 'preview_card_fetch:1:present', 'true'

      subject.call(status)

      expect(Redis.current.exists('preview_card_fetch:1:present')).to eq false
    end
  end

  context 'in a remote status' do
    let(:status) { Fabricate(:status, account: Fabricate(:account, domain: 'example.com'), text: 'Habt ihr ein paar gute Links zu #<span class="tag"><a href="https://quitter.se/tag/wannacry" target="_blank" rel="tag noopener" title="https://quitter.se/tag/wannacry">Wannacry</a></span> herumfliegen?   Ich will mal unter <br> <a href="https://github.com/qbi/WannaCry" target="_blank" rel="noopener" title="https://github.com/qbi/WannaCry">https://github.com/qbi/WannaCry</a> was sammeln. !<a href="http://sn.jonkman.ca/group/416/id" target="_blank" rel="noopener" title="http://sn.jonkman.ca/group/416/id">security</a>&nbsp;') }

    it 'parses out URLs' do
      subject.call(status)
      expect(a_request(:head, 'https://github.com/qbi/WannaCry')).to have_been_made.at_least_once
    end

    it 'ignores URLs to hashtags' do
      subject.call(status)
      expect(a_request(:head, 'https://quitter.se/tag/wannacry')).to_not have_been_made
    end
  end
end
