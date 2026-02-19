# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'Status::Visibility' do
  describe 'Validations' do
    context 'when status is a reblog' do
      subject { Fabricate.build :status, reblog: Fabricate(:status) }

      it { is_expected.to allow_values('public', 'unlisted', 'private').for(:visibility) }
      it { is_expected.to_not allow_values('direct', 'limited').for(:visibility) }
    end

    context 'when status is not reblog' do
      subject { Fabricate.build :status, reblog_of_id: nil }

      it { is_expected.to allow_values('public', 'unlisted', 'private', 'direct', 'limited').for(:visibility) }
    end
  end

  describe 'Scopes' do
    let!(:direct_status) { Fabricate :status, visibility: :direct }
    let!(:limited_status) { Fabricate :status, visibility: :limited }
    let!(:private_status) { Fabricate :status, visibility: :private }
    let!(:public_status) { Fabricate :status, visibility: :public }
    let!(:unlisted_status) { Fabricate :status, visibility: :unlisted }

    describe '.list_eligible_visibility' do
      it 'returns appropriate records' do
        expect(Status.list_eligible_visibility)
          .to include(
            private_status,
            public_status,
            unlisted_status
          )
          .and not_include(direct_status)
          .and not_include(limited_status)
      end
    end

    describe '.distributable_visibility' do
      it 'returns appropriate records' do
        expect(Status.distributable_visibility)
          .to include(
            public_status,
            unlisted_status
          )
          .and not_include(private_status)
          .and not_include(direct_status)
          .and not_include(limited_status)
      end
    end

    describe '.not_direct_visibility' do
      it 'returns appropriate records' do
        expect(Status.not_direct_visibility)
          .to include(
            limited_status,
            private_status,
            public_status,
            unlisted_status
          )
          .and not_include(direct_status)
      end
    end
  end

  describe 'Callbacks' do
    describe 'Setting visibility in before validation' do
      subject { Fabricate.build :status, visibility: nil }

      context 'when explicit value is set' do
        before { subject.visibility = :public }

        it 'does not change' do
          expect { subject.valid? }
            .to_not change(subject, :visibility)
        end
      end

      context 'when status is a reblog' do
        before { subject.reblog = Fabricate(:status, visibility: :public) }

        it 'changes to match the reblog' do
          expect { subject.valid? }
            .to change(subject, :visibility).to('public')
        end
      end

      context 'when account is locked' do
        before { subject.account = Fabricate.build(:account, locked: true) }

        it 'changes to private' do
          expect { subject.valid? }
            .to change(subject, :visibility).to('private')
        end
      end

      context 'when account is not locked' do
        before { subject.account = Fabricate.build(:account, locked: false) }

        it 'changes to public' do
          expect { subject.valid? }
            .to change(subject, :visibility).to('public')
        end
      end
    end
  end

  describe '.selectable_visibilities' do
    it 'returns options available for default privacy selection' do
      expect(Status.selectable_visibilities)
        .to match(%w(public unlisted private))
    end
  end

  describe '#hidden?' do
    subject { Status.new }

    context 'when visibility is private' do
      before { subject.visibility = :private }

      it { is_expected.to be_hidden }
    end

    context 'when visibility is direct' do
      before { subject.visibility = :direct }

      it { is_expected.to be_hidden }
    end

    context 'when visibility is limited' do
      before { subject.visibility = :limited }

      it { is_expected.to be_hidden }
    end

    context 'when visibility is public' do
      before { subject.visibility = :public }

      it { is_expected.to_not be_hidden }
    end

    context 'when visibility is unlisted' do
      before { subject.visibility = :unlisted }

      it { is_expected.to_not be_hidden }
    end
  end

  describe '#distributable?' do
    subject { Status.new }

    context 'when visibility is public' do
      before { subject.visibility = :public }

      it { is_expected.to be_distributable }
    end

    context 'when visibility is unlisted' do
      before { subject.visibility = :unlisted }

      it { is_expected.to be_distributable }
    end

    context 'when visibility is private' do
      before { subject.visibility = :private }

      it { is_expected.to_not be_distributable }
    end

    context 'when visibility is direct' do
      before { subject.visibility = :direct }

      it { is_expected.to_not be_distributable }
    end

    context 'when visibility is limited' do
      before { subject.visibility = :limited }

      it { is_expected.to_not be_distributable }
    end
  end
end
