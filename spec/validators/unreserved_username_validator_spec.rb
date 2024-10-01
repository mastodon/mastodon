# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnreservedUsernameValidator do
  let(:record_class) do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :username

      validates_with UnreservedUsernameValidator
    end
  end
  let(:record) { record_class.new }

  describe '#validate' do
    context 'when username is nil' do
      it 'does not add errors' do
        record.username = nil

        expect(record).to be_valid
        expect(record.errors).to be_empty
      end
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

          it 'adds errors to the record' do
            record.username = 'username'

            expect(record).to_not be_valid
            expect(record.errors.first.attribute).to eq(:username)
            expect(record.errors.first.type).to eq(:reserved)
          end
        end

        context 'when the account does not exist' do
          before do
            allow(Rpam2).to receive(:account).with(service, 'username').and_return(false)
          end

          it 'does not add errors to the record' do
            record.username = 'username'

            expect(record).to be_valid
            expect(record.errors).to be_empty
          end
        end
      end

      context 'without a pam service' do
        before do
          allow(Devise).to receive(:pam_controlled_service).and_return(false)
        end

        context 'when there are not any reserved usernames' do
          before do
            stub_reserved_usernames(nil)
          end

          it 'does not add errors to the record' do
            record.username = 'username'

            expect(record).to be_valid
            expect(record.errors).to be_empty
          end
        end

        context 'when there are reserved usernames' do
          before do
            stub_reserved_usernames(%w(alice bob))
          end

          context 'when the username is reserved' do
            it 'adds errors to the record' do
              record.username = 'alice'

              expect(record).to_not be_valid
              expect(record.errors.first.attribute).to eq(:username)
              expect(record.errors.first.type).to eq(:reserved)
            end
          end

          context 'when the username is not reserved' do
            it 'does not add errors to the record' do
              record.username = 'chris'

              expect(record).to be_valid
              expect(record.errors).to be_empty
            end
          end
        end

        def stub_reserved_usernames(value)
          allow(Setting).to receive(:[]).with('reserved_usernames').and_return(value)
        end
      end
    end
  end
end
