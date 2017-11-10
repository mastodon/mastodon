require 'rails_helper'

RSpec.describe PreviewCard, type: :model do
  describe '#save_with_optional_image!' do
    let(:preview_card) { Fabricate(:preview_card) }

    context 'object is valid' do
      it 'keeps image' do
        preview_card.save_with_optional_image!
        expect(preview_card.image.present?).to be true
      end
    end

    context 'object is invalid' do
      before do
        c = 0

        allow(preview_card).to receive(:save!) do
          c += 1
          raise ActiveRecord::RecordInvalid if c <= 1
        end
      end

      it 'removes image' do
        preview_card.save_with_optional_image!
        expect(preview_card.image.present?).to be false
      end
    end
  end
end
