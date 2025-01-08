# frozen_string_literal: true

RSpec.shared_examples 'Expireable' do
  subject { described_class.new(expires_at: expires_at) }

  let(:expires_at) { nil }

  describe 'Scopes' do
    let!(:expired_record) do
      travel_to 2.days.ago do
        Fabricate factory_name, expires_at: 1.day.from_now
      end
    end
    let!(:un_expired_record) { Fabricate factory_name, expires_at: 10.days.from_now }

    describe '.expired' do
      it 'returns expired records' do
        expect(described_class.expired)
          .to include(expired_record)
          .and not_include(un_expired_record)
      end
    end
  end

  describe '#expires_in' do
    context 'when expires at is nil' do
      let(:expires_at) { nil }

      it 'returns nil' do
        expect(subject.expires_in)
          .to be_nil
      end
    end
  end

  describe '#expires_in=' do
    let(:record) { Fabricate.build factory_name }

    context 'when set to nil' do
      it 'sets expires_at to nil' do
        record.expires_in = nil
        expect(record.expires_at)
          .to be_nil
      end
    end

    context 'when set to empty' do
      it 'sets expires_at to nil' do
        record.expires_in = ''
        expect(record.expires_at)
          .to be_nil
      end
    end

    context 'when set to a value' do
      it 'sets expires_at to expected future time' do
        record.expires_in = 60
        expect(record.expires_at)
          .to be_within(0.1).of(60.seconds.from_now)
      end
    end
  end

  describe '#expired?' do
    context 'when expires_at is nil' do
      let(:expires_at) { nil }

      it { is_expected.to_not be_expired }
    end

    context 'when expires_at is in the past' do
      let(:expires_at) { 5.days.ago }

      it { is_expected.to be_expired }
    end

    context 'when expires_at is in the future' do
      let(:expires_at) { 5.days.from_now }

      it { is_expected.to_not be_expired }
    end

    describe '#expire!' do
      subject { Fabricate factory_name }

      it 'updates the timestamp' do
        expect { subject.expire! }
          .to change(subject, :expires_at)
      end
    end

    describe '#expires?' do
      context 'when value is missing' do
        let(:expires_at) { nil }

        it { is_expected.to_not be_expires }
      end

      context 'when value is present' do
        let(:expires_at) { 3.days.from_now }

        it { is_expected.to be_expires }
      end
    end
  end

  def factory_name
    described_class.name.underscore.to_sym
  end
end
