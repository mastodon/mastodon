# frozen_string_literal: true

require 'rails_helper'

describe InviteCodeValidator do
  describe '#validate' do
    around do |example|
      open_registrations = Setting.open_registrations
      example.run
      Setting.open_registrations = open_registrations
    end

    it 'adds an error when registrations closed and no invite code' do
      Setting.open_registrations = false
      user = double(errors: double(add: nil), invite_code: '')
      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end

    it 'adds an error when registrations closed and invalid invite code' do
      Setting.open_registrations = false
      user = double(errors: double(add: nil), invite_code: 'FooBar123')
      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end

    it 'adds an error when expired invite code' do
      Setting.open_registrations = true

      invite = Fabricate(:invite, expires_at: 12.hours.ago)
      user   = double(errors: double(add: nil), invite_code: invite.code)

      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end

    it 'no error and set invite when closed registrations and valid invite code' do
      invite = Fabricate(:invite)

      Setting.open_registrations = false

      user = User.new(invite_code: invite.code)

      subject.validate(user)
      expect(user.invite_id).to eq invite.id
    end
  end
end
