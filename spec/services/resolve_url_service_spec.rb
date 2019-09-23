# frozen_string_literal: true

require 'rails_helper'

describe ResolveURLService, type: :service do
  subject { described_class.new }

  describe '#call' do
    it 'returns nil when there is no resource url' do
      url     = 'http://example.com/missing-resource'
      service = double

      allow(FetchResourceService).to receive(:new).and_return service
      allow(service).to receive(:call).with(url).and_return(nil)

      expect(subject.call(url)).to be_nil
    end
  end
end
