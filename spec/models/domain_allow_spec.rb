# frozen_string_literal: true

require 'rails_helper'

describe DomainAllow do
  describe 'scopes' do
    describe 'matches_domain' do
      let(:domain) { Fabricate(:domain_allow, domain: 'example.com') }
      let(:other_domain) { Fabricate(:domain_allow, domain: 'example.biz') }

      it 'returns the correct records' do
        results = described_class.matches_domain('example.com')

        expect(results).to eq([domain])
      end
    end
  end
end
