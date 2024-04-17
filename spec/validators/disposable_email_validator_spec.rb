# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DisposableEmailValidator do
  describe '#validate' do
    it 'does not allow disposable email domains' do
      user = Fabricate.build(:user, email: 'user@1994gmail.com')
      expect(user).to_not be_valid
      expect(user.errors.first.type).to eq I18n.t('disposable_email_validator.invalid')
    end

    it 'allows valid email domain' do
      user = Fabricate.build(:user, email: 'user@gmail.com')
      expect(user).to be_valid
    end
  end
end
