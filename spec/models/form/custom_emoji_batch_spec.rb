# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::CustomEmojiBatch do
  describe '#save' do
    subject { described_class.new({ current_account: account }.merge(options)) }

    let(:options) { {} }
    let(:account) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }

    context 'with empty custom_emoji_ids' do
      let(:options) { { custom_emoji_ids: [] } }

      it 'does nothing if custom_emoji_ids is empty' do
        expect(subject.save).to be_nil
      end
    end

    describe 'the update action' do
      let(:custom_emoji) { Fabricate(:custom_emoji, category: Fabricate(:custom_emoji_category)) }
      let(:custom_emoji_category) { Fabricate(:custom_emoji_category) }

      context 'without anything to change' do
        let(:options) { { action: 'update' } }

        it 'silently exits without updating any custom emojis' do
          expect { subject.save }.to_not change(Admin::ActionLog, :count)
        end
      end

      context 'with a category_id' do
        let(:options) { { action: 'update', custom_emoji_ids: [custom_emoji.id], category_id: custom_emoji_category.id } }

        it 'updates the category of the emoji' do
          subject.save

          expect(custom_emoji.reload.category).to eq(custom_emoji_category)
        end
      end

      context 'with a category_name' do
        let(:options) { { action: 'update', custom_emoji_ids: [custom_emoji.id], category_name: custom_emoji_category.name } }

        it 'updates the category of the emoji' do
          subject.save

          expect(custom_emoji.reload.category).to eq(custom_emoji_category)
        end
      end
    end

    describe 'the list action' do
      let(:custom_emoji) { Fabricate(:custom_emoji, visible_in_picker: false) }
      let(:options) { { action: 'list', custom_emoji_ids: [custom_emoji.id] } }

      it 'updates the picker visibility of the emoji' do
        subject.save

        expect(custom_emoji.reload.visible_in_picker).to be(true)
      end
    end

    describe 'the unlist action' do
      let(:custom_emoji) { Fabricate(:custom_emoji, visible_in_picker: true) }
      let(:options) { { action: 'unlist', custom_emoji_ids: [custom_emoji.id] } }

      it 'updates the picker visibility of the emoji' do
        subject.save

        expect(custom_emoji.reload.visible_in_picker).to be(false)
      end
    end

    describe 'the enable action' do
      let(:custom_emoji) { Fabricate(:custom_emoji, disabled: true) }
      let(:options) { { action: 'enable', custom_emoji_ids: [custom_emoji.id] } }

      it 'updates the disabled value of the emoji' do
        subject.save

        expect(custom_emoji.reload).to_not be_disabled
      end
    end

    describe 'the disable action' do
      let(:custom_emoji) { Fabricate(:custom_emoji, visible_in_picker: false) }
      let(:options) { { action: 'disable', custom_emoji_ids: [custom_emoji.id] } }

      it 'updates the disabled value of the emoji' do
        subject.save

        expect(custom_emoji.reload).to be_disabled
      end
    end

    describe 'the copy action' do
      let(:custom_emoji) { Fabricate(:custom_emoji) }
      let(:options) { { action: 'copy', custom_emoji_ids: [custom_emoji.id] } }

      it 'makes a copy of the emoji' do
        expect { subject.save }
          .to change(CustomEmoji, :count).by(1)
      end
    end

    describe 'the delete action' do
      let(:custom_emoji) { Fabricate(:custom_emoji) }
      let(:options) { { action: 'delete', custom_emoji_ids: [custom_emoji.id] } }

      it 'destroys the emoji' do
        subject.save

        expect { custom_emoji.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
