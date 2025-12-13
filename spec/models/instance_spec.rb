# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Instance do
  before { described_class.refresh }

  describe 'Scopes' do
    describe '#searchable' do
      let(:expected_domain) { 'host.example' }
      let(:blocked_domain) { 'other.example' }

      before do
        Fabricate :account, domain: expected_domain
        Fabricate :account, domain: blocked_domain
        Fabricate :domain_block, domain: blocked_domain
      end

      it 'returns records not domain blocked' do
        results = described_class.searchable.pluck(:domain)

        expect(results)
          .to include(expected_domain)
          .and not_include(blocked_domain)
      end
    end

    describe '#matches_domain' do
      let(:host_domain) { 'host.example.com' }
      let(:host_under_domain) { 'host_under.example.com' }
      let(:other_domain) { 'other.example' }

      before do
        Fabricate :account, domain: host_domain
        Fabricate :account, domain: host_under_domain
        Fabricate :account, domain: other_domain
      end

      it 'returns matching records' do
        expect(described_class.matches_domain('host.exa').pluck(:domain))
          .to include(host_domain)
          .and not_include(other_domain)

        expect(described_class.matches_domain('ple.com').pluck(:domain))
          .to include(host_domain)
          .and not_include(other_domain)

        expect(described_class.matches_domain('example').pluck(:domain))
          .to include(host_domain)
          .and include(other_domain)

        expect(described_class.matches_domain('host_').pluck(:domain)) # Preserve SQL wildcards
          .to include(host_domain)
          .and include(host_under_domain)
          .and not_include(other_domain)
      end
    end

    describe '#by_domain_and_subdomains' do
      let(:exact_match_domain) { 'example.com' }
      let(:subdomain_domain) { 'foo.example.com' }
      let(:partial_domain) { 'grexample.com' }

      before do
        Fabricate(:account, domain: exact_match_domain)
        Fabricate(:account, domain: subdomain_domain)
        Fabricate(:account, domain: partial_domain)
      end

      it 'returns matching instances' do
        results = described_class.by_domain_and_subdomains('example.com').pluck(:domain)

        expect(results)
          .to include(exact_match_domain)
          .and include(subdomain_domain)
          .and not_include(partial_domain)
      end
    end

    describe '#with_domain_follows' do
      let(:example_domain) { 'example.host' }
      let(:other_domain) { 'other.host' }
      let(:none_domain) { 'none.host' }

      before do
        example_account = Fabricate(:account, domain: example_domain)
        other_account = Fabricate(:account, domain: other_domain)
        Fabricate(:account, domain: none_domain)

        Fabricate :follow, account: example_account
        Fabricate :follow, target_account: other_account
      end

      it 'returns instances with domain accounts that have follows' do
        results = described_class.with_domain_follows(['example.host', 'other.host', 'none.host']).pluck(:domain)

        expect(results)
          .to include(example_domain)
          .and include(other_domain)
          .and not_include(none_domain)
      end
    end
  end
end
