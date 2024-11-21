# frozen_string_literal: true

RSpec.shared_examples 'BrowserDetection' do
  subject { described_class.new(user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Safari/605.1.15') }

  describe '#detection' do
    it 'sets a Browser instance as detection' do
      expect(subject.detection)
        .to be_a(Browser::Safari)
    end
  end

  describe '#browser' do
    it 'returns browser name from id' do
      expect(subject.browser)
        .to eq(:safari)
    end
  end

  describe '#platform' do
    it 'returns detected platform' do
      expect(subject.platform)
        .to eq(:mac)
    end
  end

  describe 'Callbacks' do
    describe 'populating the user_agent value' do
      subject { Fabricate.build described_class.name.underscore.to_sym, user_agent: nil }

      it 'changes nil to empty string' do
        expect { subject.save }
          .to change(subject, :user_agent).from(nil).to('')
      end
    end
  end
end
