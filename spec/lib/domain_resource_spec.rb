# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DomainResource do
  describe '#mx' do
    subject { described_class.new(domain) }

    let(:domain) { 'example.host' }
    let(:exchange) { 'mx.host' }

    before { configure_mx(domain: domain, exchange: exchange) }

    it 'returns array of hostnames' do
      expect(subject.mx)
        .to eq([exchange])
    end
  end
end
