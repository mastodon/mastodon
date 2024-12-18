# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeaturedTag do
  describe 'Normalizations' do
    describe 'name' do
      it { is_expected.to normalize(:name).from('  #hashtag  ').to('hashtag') }
    end
  end

  describe 'Validations' do
    context 'when account already has a featured tag' do
      subject { Fabricate.build :featured_tag, account: account }

      before { Fabricate :featured_tag, account: account, name: 'Test' }

      let(:account) { Fabricate :account }

      it { is_expected.to_not allow_value('Test').for(:name) }

      context 'when account has hit limit' do
        before { stub_const 'FeaturedTag::LIMIT', 1 }

        context 'with a local account' do
          let(:account) { Fabricate :account, domain: nil }

          it { is_expected.to_not allow_value(account).for(:account).against(:base).with_message(I18n.t('featured_tags.errors.limit')) }
        end

        context 'with a remote account' do
          let(:account) { Fabricate :account, domain: 'host.example' }

          it { is_expected.to allow_value(account).for(:account) }
        end
      end
    end
  end

  describe 'Callback to set the tag' do
    context 'with no matching tag' do
      it 'creates a new tag' do
        expect { Fabricate :featured_tag, name: 'tag' }
          .to change(Tag, :count).by(1)
      end
    end

    context 'with a matching tag' do
      it 'creates a new tag' do
        tag = Fabricate :tag, name: 'tag'

        expect { Fabricate :featured_tag, name: 'tag' }
          .to_not change(Tag, :count)

        expect(described_class.last.tag)
          .to eq(tag)
      end
    end
  end

  describe 'Callback to set the stats' do
    context 'when no statuses are relevant' do
      it 'sets values to nil' do
        featured_tag = Fabricate :featured_tag

        expect(featured_tag)
          .to have_attributes(
            statuses_count: 0,
            last_status_at: be_nil
          )
      end
    end

    context 'when some statuses are relevant' do
      it 'sets values to nil' do
        tag = Fabricate :tag, name: 'test'
        status = Fabricate :status, visibility: :public, created_at: 10.days.ago
        status.tags << tag

        featured_tag = Fabricate :featured_tag, name: 'test', account: status.account

        expect(featured_tag)
          .to have_attributes(
            statuses_count: 1,
            last_status_at: be_within(0.1).of(status.created_at)
          )
      end
    end
  end

  describe '#sign?' do
    it { is_expected.to be_sign }
  end

  describe '#display_name' do
    subject { Fabricate.build :featured_tag, name: name, tag: tag }

    context 'with a name value present' do
      let(:name) { 'Test' }
      let(:tag) { nil }

      it 'uses name value' do
        expect(subject.display_name).to eq('Test')
      end
    end

    context 'with a missing name value but a present tag' do
      let(:name) { nil }
      let(:tag) { Fabricate.build :tag, name: 'Tester' }

      it 'uses name value' do
        expect(subject.display_name).to eq('Tester')
      end
    end
  end

  describe '#increment' do
    it 'increases the count and updates the last_status_at timestamp' do
      featured_tag = Fabricate :featured_tag
      timestamp = 5.days.ago

      expect { featured_tag.increment(timestamp) }
        .to change(featured_tag, :statuses_count).from(0).to(1)
        .and change(featured_tag, :last_status_at).from(nil).to(be_within(0.1).of(timestamp))
    end
  end

  describe '#decrement' do
    it 'decreases the count and updates the last_status_at timestamp' do
      tag = Fabricate :tag, name: 'test'
      status = Fabricate :status, visibility: :public, created_at: 10.days.ago
      status.tags << tag

      featured_tag = Fabricate :featured_tag, name: 'test', account: status.account

      expect { featured_tag.decrement(status.id) }
        .to change(featured_tag, :statuses_count).from(1).to(0)
        .and change(featured_tag, :last_status_at).to(nil)
    end
  end
end
