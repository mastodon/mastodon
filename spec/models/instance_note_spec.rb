# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstanceNote do
  describe 'latest' do
    it 'returns the instance notes sorted by oldest first' do
      instance = Instance.find_or_initialize_by(domain: TagManager.instance.normalize_domain('example.org'))

      note1 = Fabricate(:instance_note, domain: 'example.org')
      note2 = Fabricate(:instance_note, domain: 'example.org')

      expect(instance.notes.latest).to eq [note1, note2]
    end
  end

  describe 'validations' do
    it 'is invalid if the content is empty' do
      note = Fabricate.build(:instance_note, domain: 'example.org', content: '')
      expect(note.valid?).to be false
    end

    it 'is invalid if content is longer than character limit' do
      note = Fabricate.build(:instance_note, domain: 'example.org', content: comment_over_limit)
      expect(note.valid?).to be false
    end

    it 'is valid if the instance does not yet exist' do
      note = Fabricate.build(:instance_note, domain: 'non-existent.example', content: 'test comment')
      expect(note.valid?).to be true
    end

    def comment_over_limit
      Faker::Lorem.paragraph_by_chars(number: described_class::CONTENT_SIZE_LIMIT * 2)
    end
  end
end
