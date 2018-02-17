# frozen_string_literal: true

require 'rails_helper'

describe TextBlocksValidator do
  class Model
    include ActiveModel::Validations
    validates :text, text_blocks: true
  end

  it 'says valid if given value is nil' do
    class Model
      def text
        nil
      end
    end

    expect(Model.new).to be_valid
  end

  it 'says valid if given value does not have rejected texts' do
    class Model
      def text
        'valid'
      end
    end

    Fabricate(:text_block, text: 'rejected', severity: :reject)

    expect(Model.new).to be_valid
  end

  it 'says invalid if given value has rejected texts' do
    class Model
      def text
        'rejected'
      end
    end

    Fabricate(:text_block, text: 'rejected', severity: :reject)

    model = Model.new
    expect(model).to be_invalid
    expect(model.errors[:text]).to eq [I18n.t('rejected_text', text: 'rejected')]
  end
end
