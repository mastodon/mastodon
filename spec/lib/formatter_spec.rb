require 'rails_helper'

RSpec.describe Formatter do
  let(:account)       { Fabricate(:account, username: 'alice') }
  let(:local_text)    { 'Hello world http://google.com' }
  let(:local_status)  { Fabricate(:status, text: local_text, account: account) }
  let(:remote_status) { Fabricate(:status, text: '<script>alert("Hello")</script> Beep boop', uri: 'beepboop', account: account) }

  describe '#format' do
    subject { Formatter.instance.format(local_status) }

    it 'returns a string' do
      expect(subject).to be_a String
    end

    it 'contains plain text' do
      expect(subject).to match('Hello world')
    end

    it 'contains a link' do
      expect(subject).to match('<a href="http://google.com" rel="nofollow noopener" target="_blank"><span class="invisible">http://</span><span class="">google.com</span><span class="invisible"></span></a>')
    end

    context 'matches a stand-alone medium URL' do
      let(:local_text) { 'https://hackernoon.com/the-power-to-build-communities-a-response-to-mark-zuckerberg-3f2cac9148a4' }
      it 'has valid url' do
        expect(subject).to include('href="https://hackernoon.com/the-power-to-build-communities-a-response-to-mark-zuckerberg-3f2cac9148a4"')
      end
    end

    context 'matches a stand-alone google URL' do
      let(:local_text) { 'http://google.com' }
      it 'has valid url' do
        expect(subject).to include('href="http://google.com"')
      end
    end

    context 'matches a URL without trailing period' do
      let(:local_text) { 'http://www.mcmansionhell.com/post/156408871451/50-states-of-mcmansion-hell-scottsdale-arizona. ' }
      it 'has valid url' do
        expect(subject).to include('href="http://www.mcmansionhell.com/post/156408871451/50-states-of-mcmansion-hell-scottsdale-arizona"')
      end
    end

=begin
    it 'matches a URL without closing paranthesis' do
      expect(subject.match('(http://google.com/)')[0]).to eq 'http://google.com'
    end
=end

    context 'matches a URL without exclamation point' do
      let(:local_text) { 'http://www.google.com!' }
      it 'has valid url' do
        expect(subject).to include('href="http://www.google.com"')
      end
    end

    context 'matches a URL without single quote' do
      let(:local_text) { "http://www.google.com'" }
      it 'has valid url' do
        expect(subject).to include('href="http://www.google.com"')
      end
    end

    context 'matches a URL without angle brackets' do
      let(:local_text) { 'http://www.google.com>' }
      it 'has valid url' do
        expect(subject).to include('href="http://www.google.com"')
      end
    end

    context 'matches a URL with a query string' do
      let(:local_text) { 'https://www.ruby-toolbox.com/search?utf8=%E2%9C%93&q=autolink' }
      it 'has valid url' do
        expect(subject).to include('href="https://www.ruby-toolbox.com/search?utf8=%E2%9C%93&amp;q=autolink"')
      end
    end

    context 'matches a URL with parenthesis in it' do
      let(:local_text) { 'https://en.wikipedia.org/wiki/Diaspora_(software)' }
      it 'has valid url' do
        expect(subject).to include('href="https://en.wikipedia.org/wiki/Diaspora_(software)"')
      end
    end

    context 'contains html (script tag)' do
        let(:local_text) { '<script>alert("Hello")</script>' }
        it 'has valid url' do
            expect(subject).to match '<p>&lt;script&gt;alert(&quot;Hello&quot;)&lt;/script&gt;</p>'
        end
    end

    context 'contains html (xss attack)' do
      let(:local_text) { %q{<img src="javascript:alert('XSS');">} }
      it 'has valid url' do
        expect(subject).to match '<p>&lt;img src=&quot;javascript:alert(&apos;XSS&apos;);&quot;&gt;</p>'
      end
    end
  end

  describe '#reformat' do
    subject { Formatter.instance.format(remote_status) }

    it 'returns a string' do
      expect(subject).to be_a String
    end

    it 'contains plain text' do
      expect(subject).to match('Beep boop')
    end

    it 'does not contain scripts' do
      expect(subject).to_not match('<script>alert("Hello")</script>')
    end
  end
end
