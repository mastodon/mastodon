# frozen_string_literal: true

require 'rails_helper'

describe UniqueUsernameValidator do
  describe '#validate' do
    it 'does not add errors if username is nil' do
      account = double(username: nil, persisted?: false, errors: double(add: nil))
      subject.validate(account)
      expect(account.errors).to_not have_received(:add)
    end

    it 'does not add errors when existing one is subject itself' do
      account = Fabricate(:account, username: 'abcdef')
      expect(account).to be_valid
    end

    it 'adds an error when the username is already used with ignoring dots' do
      pending 'allowing dots in username is still in development'
      Fabricate(:account, username: 'abcd.ef')
      account = double(username: 'ab.cdef', persisted?: false, errors: double(add: nil))
      subject.validate(account)
      expect(account.errors).to have_received(:add)
    end

    it 'adds an error when the username is already used with ignoring cases' do
      Fabricate(:account, username: 'ABCdef')
      account = double(username: 'abcDEF', persisted?: false, errors: double(add: nil))
      subject.validate(account)
      expect(account.errors).to have_received(:add)
    end
  end
end
