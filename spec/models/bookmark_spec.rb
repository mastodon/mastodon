# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bookmark do
  describe 'Associations' do
    it { is_expected.to belong_to(:account).required }
    it { is_expected.to belong_to(:status).required }
  end

  describe 'Validations' do
    subject { Fabricate.build :bookmark }

    it { is_expected.to validate_uniqueness_of(:status_id).scoped_to(:account_id) }
  end

  describe 'Callbacks' do
    describe 'reblog statuses' do
      context 'when status is not a reblog' do
        let(:status) { Fabricate :status }

        it 'keeps status set to assigned value' do
          bookmark = Fabricate.build :bookmark, status: status

          expect { bookmark.valid? }
            .to_not change(bookmark, :status)
        end
      end

      context 'when status is a reblog' do
        let(:original) { Fabricate :status }
        let(:status) { Fabricate :status, reblog: original }

        it 'keeps status set to assigned value' do
          bookmark = Fabricate.build :bookmark, status: status

          expect { bookmark.valid? }
            .to change(bookmark, :status).to(original)
        end
      end
    end
  end
end
