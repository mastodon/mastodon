# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::ActorSerializer do
  subject { serialized_record_json(record, described_class) }

  describe '#type' do
    context 'with the instance actor' do
      let(:record) { Account.find(Account::INSTANCE_ACTOR_ID) }

      it { is_expected.to include('type' => 'Application') }
    end

    context 'with an application actor' do
      let(:record) { Fabricate :account, actor_type: 'Application' }

      it { is_expected.to include('type' => 'Service') }
    end

    context 'with a service actor' do
      let(:record) { Fabricate :account, actor_type: 'Service' }

      it { is_expected.to include('type' => 'Service') }
    end

    context 'with a Group actor' do
      let(:record) { Fabricate :account, actor_type: 'Group' }

      it { is_expected.to include('type' => 'Group') }
    end

    context 'with a Person actor' do
      let(:record) { Fabricate :account, actor_type: 'Person' }

      it { is_expected.to include('type' => 'Person') }
    end
  end
end
