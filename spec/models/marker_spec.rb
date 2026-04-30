# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Marker do
  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:timeline) }
    it { is_expected.to validate_inclusion_of(:timeline).in_array(described_class::TIMELINES) }
  end

  describe '.record' do
    subject { described_class.record(user, args) }

    let(:user) { Fabricate :user }
    let(:args) { { home: { last_read_id: '123456' } } }

    context 'with a user that does not have markers' do
      it 'creates markers for the user' do
        expect { expect(subject).to include(home: be_a(described_class)) }
          .to change { user.markers.count }.by(1)
      end
    end

    context 'with a user that has markers' do
      before { Fabricate :marker, timeline: 'home', last_read_id: 999, user: }

      it 'updates markers for the user' do
        expect { expect(subject).to include(home: be_a(described_class)) }
          .to not_change { user.markers.count }
          .and(change { user.markers.first.last_read_id })
      end
    end
  end
end
