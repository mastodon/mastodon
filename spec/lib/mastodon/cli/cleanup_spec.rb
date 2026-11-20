# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/cleanup'

RSpec.describe Mastodon::CLI::Cleanup do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#accounts' do
    let(:action) { :accounts }
    let(:delete_account_service) { instance_double(DeleteAccountService, call: nil) }

    before do
      allow(DeleteAccountService).to receive(:new).and_return(delete_account_service)
    end

    context 'when no option is given' do
      it 'exits with an error message' do
        expect { subject }
          .to raise_error(Thor::Error, /Please specify at least one cleanup category/)
      end
    end

    context 'with category options' do
      let!(:suspended_domain_block) { Fabricate(:domain_block, domain: 'suspended-instance.com', severity: :suspend) }
      let!(:specific_domain_account) { Fabricate(:account, domain: 'target-domain.com') }
      let!(:active_remote_account) { Fabricate(:account, domain: 'active-instance.com') }

      before do
        allow(DeliveryFailureTracker).to receive(:warning_domains).and_return(['failing-instance.com'])
      end

      context 'with --domain' do
        let(:options) { { domain: 'TARGET-DOMAIN.COM' } }

        it 'deletes remote accounts from specified domain case-insensitively' do
          expect { subject }
            .to output_results('OK, cleaned up 1 accounts, 0 statuses, 0 media attachments (approx. 0 Bytes)')

          expect(delete_account_service).to have_received(:call).with(specific_domain_account, reserve_username: false, reserve_email: false, skip_side_effects: true).once
          expect(delete_account_service).to_not have_received(:call).with(active_remote_account, any_args)
        end
      end

      context 'with --suspended-instances' do
        let(:options) { { suspended_instances: true } }

        it 'deletes accounts on suspended instances only and keeps domain block intact' do
          expect { subject }
            .to output_results('OK, cleaned up 1 accounts, 0 statuses, 0 media attachments (approx. 0 Bytes)')

          expect(delete_account_service).to have_received(:call).with(account_on_suspended_instance, reserve_username: false, reserve_email: false, skip_side_effects: true).once
          expect(DomainBlock.exists?(id: suspended_domain_block.id)).to be(true)
        end
      end
    end
  end
end
