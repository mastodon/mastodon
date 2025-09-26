# frozen_string_literal: true

RSpec.shared_examples 'FollowLimitable' do
  describe 'Validations' do
    subject { Fabricate.build factory_name, rate_limit: true }

    let(:account) { Fabricate(:account) }

    context 'when account follows too many people' do
      before { account.update(following_count: FollowLimitValidator::LIMIT) }

      it { is_expected.to_not allow_value(account).for(:account).against(:base) }
    end

    context 'when account is on brink of following too many people' do
      before { account.update(following_count: FollowLimitValidator::LIMIT - 1) }

      it { is_expected.to allow_value(account).for(:account).against(:base) }
    end
  end

  describe '#local?' do
    it { is_expected.to_not be_local }
  end

  describe 'Callbacks' do
    describe 'Setting a URI' do
      context 'when URI exists' do
        subject { Fabricate.build factory_name, uri: 'https://uri/value' }

        it 'does not change' do
          expect { subject.save }
            .to not_change(subject, :uri)
        end
      end

      context 'when URI is blank' do
        subject { Fabricate.build factory_name, uri: nil }

        it 'populates the value' do
          expect { subject.save }
            .to change(subject, :uri).to(be_present)
        end
      end
    end

    describe 'Managing the cache' do
      subject { Fabricate.build factory_name, account: }

      context 'when the follow recommendations cache has a value' do
        before { Rails.cache.write(cache_key, 'Value') }

        let(:account) { Fabricate :account }
        let(:cache_key) { "follow_recommendations/#{account.id}" }

        it 'invalidates cache on save' do
          expect { subject.save }
            .to(change { Rails.cache.read(cache_key) }.from('Value').to(be_blank))
        end
      end
    end
  end

  def factory_name
    described_class.name.underscore.to_sym
  end
end
