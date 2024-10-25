# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountMigration do
  describe 'Normalizations' do
    describe 'acct' do
      it { is_expected.to normalize(:acct).from('  @username@domain  ').to('username@domain') }
    end
  end

  describe 'Validations' do
    subject { Fabricate.build :account_migration, account: source_account }

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

      it { is_expected.to allow_value(target_account.acct).for(:acct) }
    end

    context 'with unresolvable account' do
      let(:target_acct) { 'target@remote' }

      before do
        service_double = instance_double(ResolveAccountService)
        allow(ResolveAccountService).to receive(:new).and_return(service_double)
        allow(service_double).to receive(:call).with(target_acct, anything).and_return(nil)
      end

      it { is_expected.to_not allow_value(target_acct).for(:acct) }
    end

    context 'with a space in the domain part' do
      let(:target_acct) { 'target@remote. org' }

      it { is_expected.to_not allow_value(target_acct).for(:acct) }
    end
  end
end
