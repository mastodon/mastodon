# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/domains'

describe Mastodon::CLI::Domains do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#purge' do
    let(:action) { :purge }

    context 'with invalid limited federation mode argument' do
      let(:arguments) { ['example.host'] }
      let(:options) { { limited_federation_mode: true } }

      it 'warns about usage and exits' do
        expect { subject }
          .to raise_error(Thor::Error, /DOMAIN parameter not supported/)
      end
    end

    context 'without a domains argument' do
      it 'warns about usage and exits' do
        expect { subject }
          .to raise_error(Thor::Error, 'No domain(s) given')
      end
    end

    context 'with accounts from the domain' do
      let(:domain) { 'host.example' }
      let!(:account) { Fabricate(:account, domain: domain) }
      let(:arguments) { [domain] }

      it 'removes the account' do
        expect { subject }
          .to output_results('Removed 1 accounts')

        expect { account.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#crawl' do
    let(:action) { :crawl }

    context 'with accounts from the domain' do
      let(:domain) { 'host.example' }

      before do
        Fabricate(:account, domain: domain)
        stub_request(:get, 'https://host.example/api/v1/instance').to_return(status: 200, body: {}.to_json)
        stub_request(:get, 'https://host.example/api/v1/instance/peers').to_return(status: 200, body: {}.to_json)
        stub_request(:get, 'https://host.example/api/v1/instance/activity').to_return(status: 200, body: {}.to_json)
        stub_const('Mastodon::CLI::Domains::CRAWL_SLEEP_TIME', 0)
      end

      context 'with --format of summary' do
        let(:options) { { format: 'summary' } }

        it 'crawls the domains and summarizes results' do
          expect { subject }
            .to output_results('Visited 1 domains, 0 failed')
        end
      end

      context 'with --format of domains' do
        let(:options) { { format: 'domains' } }

        it 'crawls the domains and summarizes results' do
          expect { subject }
            .to output_results(domain)
        end
      end

      context 'with --format of json' do
        let(:options) { { format: 'json' } }

        it 'crawls the domains and summarizes results' do
          expect { subject }
            .to output_results(json_summary)
        end

        def json_summary
          Oj.dump('host.example': { activity: {} })
        end
      end
    end
  end
end
