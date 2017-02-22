require 'rails_helper'

RSpec.describe Formatter do
  let(:account)       { Fabricate(:account, username: 'alice') }
  let(:local_status)  { Fabricate(:status, text: 'Hello world http://google.com', account: account) }
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

=begin
    it 'matches a stand-alone medium URL' do
      expect(subject.match('https://hackernoon.com/the-power-to-build-communities-a-response-to-mark-zuckerberg-3f2cac9148a4')[0]).to eq 'https://hackernoon.com/the-power-to-build-communities-a-response-to-mark-zuckerberg-3f2cac9148a4'
    end

    it 'matches a stand-alone google URL' do
      expect(subject.match('http://google.com')[0]).to eq 'http://google.com'
    end

    it 'matches a URL without trailing period' do
      expect(subject.match('http://www.mcmansionhell.com/post/156408871451/50-states-of-mcmansion-hell-scottsdale-arizona. ')[0]).to eq 'http://www.mcmansionhell.com/post/156408871451/50-states-of-mcmansion-hell-scottsdale-arizona'
    end

    it 'matches a URL without closing paranthesis' do
      expect(subject.match('(http://google.com/)')[0]).to eq 'http://google.com'
    end

    it 'matches a URL without exclamation point' do
      expect(subject.match('http://www.google.com! ')[0]).to eq 'http://www.google.com'
    end

    it 'matches a URL with a query string' do
      expect(subject.match('https://www.ruby-toolbox.com/search?utf8=%E2%9C%93&q=autolink')[0]).to eq 'https://www.ruby-toolbox.com/search?utf8=%E2%9C%93&q=autolink'
    end

    it 'matches a URL with parenthesis in it' do
      expect(subject.match('https://en.wikipedia.org/wiki/Diaspora_(software)')[0]).to eq 'https://en.wikipedia.org/wiki/Diaspora_(software)'
    end
=end
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
