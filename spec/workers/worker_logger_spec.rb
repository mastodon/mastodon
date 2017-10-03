require 'rails_helper'

describe WorkerLogger do
  subject { dummy_class.new }
	let(:dummy_class) { Class.new { include WorkerLogger; def logger; end } }

  before do
    logger = double(Rails.logger)
    allow(logger).to receive(:info)
    allow(subject).to receive(:logger).and_return(logger)
  end

  describe 'log_delay' do
    it 'logs useful information' do
      subject.log_delay('2017-09-29T14:22:30Z', 'https://example.com/api', 'delivered', Time.utc(2017, 9, 29, 14, 22, 40))
      %w(destination="https://example.com/api" measure#delivery.delay=10sec count#delivered=1).each do |info|
        expect(subject.logger).to have_received(:info).with(Regexp.new(info))
      end
    end

    it 'does not log wihout published timestamp' do
      subject.log_delay(nil, 'URL', 'delivered')
      expect(subject.logger).not_to have_received(:info)
    end

    it 'does not raise error with malformed timestamp' do
      expect { subject.log_delay('this is not time', 'URL', 'delivered') }.to_not raise_error
    end
  end
end
