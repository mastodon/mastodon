# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnouncementReaction do
  describe 'Associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:announcement).inverse_of(:announcement_reactions) }
    it { is_expected.to belong_to(:custom_emoji).optional }
  end

  describe 'Validations' do
    subject { Fabricate.build :announcement_reaction }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to allow_values('😀').for(:name) }
    it { is_expected.to_not allow_values('INVALID').for(:name) }

    context 'when reaction limit is reached' do
      subject { Fabricate.build :announcement_reaction, announcement: announcement_reaction.announcement }

      let(:announcement_reaction) { Fabricate :announcement_reaction, name: '😊' }

      before { stub_const 'ReactionValidator::LIMIT', 1 }

      it { is_expected.to_not allow_values('😀').for(:name).against(:base) }
    end
  end

  describe 'Callbacks' do
    describe 'Setting custom emoji association' do
      subject { Fabricate.build :announcement_reaction, name: }

      context 'when name is missing' do
        let(:name) { '' }

        it 'does not set association' do
          expect { subject.valid? }
            .to not_change(subject, :custom_emoji).from(be_blank)
        end
      end

      context 'when name matches a custom emoji shortcode' do
        let(:name) { 'custom' }
        let!(:custom_emoji) { Fabricate :custom_emoji, shortcode: 'custom' }

        it 'sets association' do
          expect { subject.valid? }
            .to change(subject, :custom_emoji).from(be_blank).to(custom_emoji)
        end
      end

      context 'when name does not match a custom emoji' do
        let(:name) { 'custom' }

        it 'does not set association' do
          expect { subject.valid? }
            .to not_change(subject, :custom_emoji).from(be_blank)
        end
      end
    end
  end
end
