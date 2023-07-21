# frozen_string_literal: true

require 'rails_helper'

describe UniqueUsernameValidator do
  describe '#validate' do
    context 'when local account' do
      it 'does not add errors if username is nil' do
        account = instance_double(Account, username: nil, domain: nil, persisted?: false, errors: activemodel_errors)
        subject.validate(account)
        expect(account.errors).to_not have_received(:add)
      end

      it 'does not add errors when existing one is subject itself' do
        account = Fabricate(:account, username: 'abcdef')
        expect(account).to be_valid
      end

      it 'adds an error when the username is already used with ignoring cases' do
        Fabricate(:account, username: 'ABCdef')
        account = instance_double(Account, username: 'abcDEF', domain: nil, persisted?: false, errors: activemodel_errors)
        subject.validate(account)
        expect(account.errors).to have_received(:add)
      end

      it 'does not add errors when same username remote account exists' do
        Fabricate(:account, username: 'abcdef', domain: 'example.com')
        account = instance_double(Account, username: 'abcdef', domain: nil, persisted?: false, errors: activemodel_errors)
        subject.validate(account)
        expect(account.errors).to_not have_received(:add)
      end
    end
  end

  context 'when remote account' do
    it 'does not add errors if username is nil' do
      account = instance_double(Account, username: nil, domain: 'example.com', persisted?: false, errors: activemodel_errors)
      subject.validate(account)
      expect(account.errors).to_not have_received(:add)
    end

    it 'does not add errors when existing one is subject itself' do
      account = Fabricate(:account, username: 'abcdef', domain: 'example.com')
      expect(account).to be_valid
    end

    it 'adds an error when the username is already used with ignoring cases' do
      Fabricate(:account, username: 'ABCdef', domain: 'example.com')
      account = instance_double(Account, username: 'abcDEF', domain: 'example.com', persisted?: false, errors: activemodel_errors)
      subject.validate(account)
      expect(account.errors).to have_received(:add)
    end

    it 'adds an error when the domain is already used with ignoring cases' do
      Fabricate(:account, username: 'ABCdef', domain: 'example.com')
      account = instance_double(Account, username: 'ABCdef', domain: 'EXAMPLE.COM', persisted?: false, errors: activemodel_errors)
      subject.validate(account)
      expect(account.errors).to have_received(:add)
    end

    it 'does not add errors when account with the same username and another domain exists' do
      Fabricate(:account, username: 'abcdef', domain: 'example.com')
      account = instance_double(Account, username: 'abcdef', domain: 'example2.com', persisted?: false, errors: activemodel_errors)
      subject.validate(account)
      expect(account.errors).to_not have_received(:add)
    end
  end

  private

  def activemodel_errors
    instance_double(ActiveModel::Errors, add: nil)
  end
end
