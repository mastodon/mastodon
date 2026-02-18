# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnreservedUsernameValidator do
  subject { record_class.new }

  let(:record_class) do
    Class.new do
      include ActiveModel::Validations

      attr_accessor :username

      validates_with UnreservedUsernameValidator

      def self.name = 'Record'
    end
  end

  context 'when username is nil' do
    it { is_expected.to allow_value(nil).for(:username) }
  end

  context 'when PAM is enabled' do
    before do
      allow(Devise).to receive(:pam_authentication).and_return(true)
    end

    context 'with a pam service available' do
      let(:service) { double }
      let(:pam_class) do
        Class.new do
          def self.account(service, username); end
        end
      end

      before do
        stub_const('Rpam2', pam_class)
        allow(Devise).to receive(:pam_controlled_service).and_return(service)
      end

      context 'when the account exists' do
        before do
          allow(Rpam2).to receive(:account).with(service, 'username').and_return(true)
        end

        it { is_expected.to_not allow_value('username').for(:username).with_message(:reserved) }
      end

      context 'when the account does not exist' do
        before do
          allow(Rpam2).to receive(:account).with(service, 'username').and_return(false)
        end

        it { is_expected.to allow_value('username').for(:username) }
      end
    end

    context 'without a pam service' do
      before do
        allow(Devise).to receive(:pam_controlled_service).and_return(false)
      end

      context 'when there are not any reserved usernames' do
        it { is_expected.to allow_value('username').for(:username) }
      end

      context 'when there are reserved usernames' do
        before { %w(alice bob).each { |username| Fabricate(:username_block, exact: true, username:) } }

        context 'when the username is reserved' do
          it { is_expected.to_not allow_values('alice', 'bob').for(:username).with_message(:reserved) }
        end

        context 'when the username is not reserved' do
          it { is_expected.to allow_value('chris').for(:username) }
        end
      end
    end
  end
end
