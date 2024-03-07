# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AfterUnallowDomainService do
  describe '#call' do
    context 'with accounts for a domain' do
      let!(:account) { Fabricate(:account, domain: 'host.example') }
      let!(:test_account) { Fabricate(:account, domain: 'test.example') }
      let(:service_double) { instance_double(DeleteAccountService, call: true) }

      before { allow(DeleteAccountService).to receive(:new).and_return(service_double) }

      it 'calls the delete service for accounts from the relevant domain' do
        subject.call 'test.example'

        expect(service_double)
          .to_not have_received(:call).with(account, reserve_username: false)
        expect(service_double)
          .to have_received(:call).with(test_account, reserve_username: false)
      end
    end
  end
end
