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
      expect(subject).to match('<a rel="nofollow noopener" target="_blank" href="http://google.com"><span class="invisible">http://</span><span class="ellipsis">google.com</span><span class="invisible"></span></a>')
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
