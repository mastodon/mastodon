# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignatureParser do
  describe '.parse' do
    subject { described_class.parse(header) }

    context 'with Signature headers conforming to draft-cavage-http-signatures-12' do
      let(:header) do
        # This example signature string deliberately mixes uneven spacing
        # and quoting styles to ensure everything is covered
        'keyId = "https://remote.domain/users/bob#main-key,",algorithm=  rsa-sha256 ,  headers="host date digest (request-target)",signature="gmhMjgMROGElJU3fpehV2acD5kMHeELi8EFP2UPHOdQ54H0r55AxIpji+J3lPe+N2qSb/4H1KXIh6f0lRu8TGSsu12OQmg5hiO8VA9flcA/mh9Lpk+qwlQZIPRqKP9xUEfqD+Z7ti5wPzDKrWAUK/7FIqWgcT/mlqB1R1MGkpMFc/q4CIs2OSNiWgA4K+Kp21oQxzC2kUuYob04gAZ7cyE/FTia5t08uv6lVYFdRsn4XNPn1MsHgFBwBMRG79ng3SyhoG4PrqBEi5q2IdLq3zfre/M6He3wlCpyO2VJNdGVoTIzeZ0Zz8jUscPV3XtWUchpGclLGSaKaq/JyNZeiYQ=="' # rubocop:disable Layout/LineLength
      end

      it 'correctly parses the header' do
        expect(subject).to eq({
          'keyId' => 'https://remote.domain/users/bob#main-key,',
          'algorithm' => 'rsa-sha256',
          'headers' => 'host date digest (request-target)',
          'signature' => 'gmhMjgMROGElJU3fpehV2acD5kMHeELi8EFP2UPHOdQ54H0r55AxIpji+J3lPe+N2qSb/4H1KXIh6f0lRu8TGSsu12OQmg5hiO8VA9flcA/mh9Lpk+qwlQZIPRqKP9xUEfqD+Z7ti5wPzDKrWAUK/7FIqWgcT/mlqB1R1MGkpMFc/q4CIs2OSNiWgA4K+Kp21oQxzC2kUuYob04gAZ7cyE/FTia5t08uv6lVYFdRsn4XNPn1MsHgFBwBMRG79ng3SyhoG4PrqBEi5q2IdLq3zfre/M6He3wlCpyO2VJNdGVoTIzeZ0Zz8jUscPV3XtWUchpGclLGSaKaq/JyNZeiYQ==', # rubocop:disable Layout/LineLength
        })
      end
    end

    context 'with a malformed Signature header' do
      let(:header) { 'hello this is malformed!' }

      it 'raises an error' do
        expect { subject }.to raise_error(described_class::ParsingError)
      end
    end
  end
end
