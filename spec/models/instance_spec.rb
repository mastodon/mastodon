# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Instance do
  describe 'Scopes' do
    before { described_class.refresh }

    describe '#searchable' do
      before do
        Fabricate :account, domain: 'host.example'
        Fabricate :account, domain: 'other.example'
        Fabricate :domain_block, domain: 'other.example'
      end

      it 'returns records not domain blocked' do
        results = described_class.searchable

        expect(results)
          .to include(expected_instance)
          .and not_include(not_expected_instance)
      end

      def expected_instance
        described_class.where(domain: 'host.example').first
      end

      def not_expected_instance
        described_class.where(domain: 'other.example').first
      end
    end

    describe '#matches_domain' do
      before do
        Fabricate :account, domain: 'host.example.com'
        Fabricate :account, domain: 'host_under.example.com'
        Fabricate :account, domain: 'other.example'
      end

      it 'returns matching records' do
        expect(described_class.matches_domain('host.exa'))
          .to include(host_instance)
          .and not_include(other_instance)

        expect(described_class.matches_domain('ple.com'))
          .to include(host_instance)
          .and not_include(other_instance)

        expect(described_class.matches_domain('example'))
          .to include(host_instance)
          .and include(other_instance)

        expect(described_class.matches_domain('host_')) # Preserve SQL wildcards
          .to include(host_instance)
          .and include(host_under_instance)
          .and not_include(other_instance)
      end

      def host_instance
        described_class.where(domain: 'host.example.com').first
      end

      def host_under_instance
        described_class.where(domain: 'host_under.example.com').first
      end

      def other_instance
        described_class.where(domain: 'other.example').first
      end
    end

    describe '#by_domain_and_subdomains' do
      before do
        Fabricate(:account, domain: 'example.com')
        Fabricate(:account, domain: 'foo.example.com')
        Fabricate(:account, domain: 'grexample.com')
      end

      it 'returns matching instances' do
        results = described_class.by_domain_and_subdomains('example.com')

        expect(results)
          .to include(exact_match_instance)
          .and include(subdomain_instance)
          .and not_include(partial_instance)
      end

      def exact_match_instance
        described_class.where(domain: 'example.com').first
      end

      def subdomain_instance
        described_class.where(domain: 'foo.example.com').first
      end

      def partial_instance
        described_class.where(domain: 'grexample.com').first
      end
    end
  end
end
