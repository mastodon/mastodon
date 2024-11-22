# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Admin::AccountSerializer do
  subject { serialized_record_json(record, described_class) }

  describe 'created_by_application_id' do
    context 'when account is application-created' do
      let(:record) { Fabricate :account, user: Fabricate(:user, created_by_application: application) }
      let(:application) { Fabricate :application }

      it { is_expected.to include('created_by_application_id' => application.id.to_s) }
    end
  end

  describe 'invited_by_account_id' do
    context 'when account was invited' do
      let(:record) { Fabricate :account, user: Fabricate(:user, invite: invite) }
      let(:invite) { Fabricate :invite }

      it { is_expected.to include('invited_by_account_id' => invite.user.account.id.to_s) }
    end
  end
end
