# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountMigration do
  describe 'validations' do
    subject { described_class.new(account: source_account, acct: target_acct) }

    let(:source_account) { Fabricate(:account) }
    let(:target_acct)    { target_account.acct }

    context 'with valid properties' do
      let(:target_account) { Fabricate(:account, username: 'target', domain: 'remote.org') }

      before do
        target_account.aliases.create!(acct: source_account.acct)

        service_double = instance_double(ResolveAccountService)
        allow(ResolveAccountService).to receive(:new).and_return(service_double)
        allow(service_double).to receive(:call).with(target_acct, anything).and_return(target_account)
      end

      it 'passes validations' do
        expect(subject).to be_valid
      end
    end

    context 'with unresolvable account' do
      let(:target_acct) { 'target@remote' }

      before do
        service_double = instance_double(ResolveAccountService)
        allow(ResolveAccountService).to receive(:new).and_return(service_double)
        allow(service_double).to receive(:call).with(target_acct, anything).and_return(nil)
      end

      it 'has errors on acct field' do
        expect(subject).to model_have_error_on_field(:acct)
      end
    end

    context 'with a space in the domain part' do
      let(:target_acct) { 'target@remote. org' }

      it 'has errors on acct field' do
        expect(subject).to model_have_error_on_field(:acct)
      end
    end
  end
end
