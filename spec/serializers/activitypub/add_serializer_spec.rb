# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::AddSerializer do
  describe '.serializer_for' do
    subject { described_class.serializer_for(model, {}) }

    context 'with a Status model' do
      let(:model) { Status.new }

      it { is_expected.to eq(described_class::UriSerializer) }
    end

    context 'with a FeaturedTag model' do
      let(:model) { FeaturedTag.new }

      it { is_expected.to eq(ActivityPub::HashtagSerializer) }
    end

    context 'with a Collection model' do
      let(:model) { Collection.new }

      it { is_expected.to eq(ActivityPub::FeaturedCollectionSerializer) }
    end

    context 'with an Array' do
      let(:model) { [] }

      it { is_expected.to eq(ActiveModel::Serializer::CollectionSerializer) }
    end
  end

  describe '#target' do
    subject { described_class.new(object).target }

    context 'when object is a Status' do
      let(:object) { Fabricate(:status) }

      it { is_expected.to match(%r{/#{object.account_id}/collections/featured$}) }
    end

    context 'when object is a FeaturedTag' do
      let(:object) { Fabricate(:featured_tag) }

      it { is_expected.to match(%r{/#{object.account_id}/collections/featured$}) }
    end

    context 'when object is a Collection' do
      let(:object) { Fabricate(:collection) }

      it { is_expected.to match(%r{/#{object.account_id}/featured_collections$}) }
    end
  end

  describe 'Serialization' do
    subject { serialized_record_json(object, described_class, adapter: ActivityPub::Adapter) }

    let(:tag_manager) { ActivityPub::TagManager.instance }

    context 'with a status' do
      let(:object) { Fabricate(:status) }

      it 'serializes to the expected json' do
        expect(subject).to include({
          'type' => 'Add',
          'actor' => tag_manager.uri_for(object.account),
          'target' => a_string_matching(%r{/featured$}),
          'object' => tag_manager.uri_for(object),
        })

        expect(subject).to_not have_key('id')
        expect(subject).to_not have_key('published')
        expect(subject).to_not have_key('to')
        expect(subject).to_not have_key('cc')
      end
    end

    context 'with a featured tag' do
      let(:object) { Fabricate(:featured_tag) }

      it 'serializes to the expected json' do
        expect(subject).to include({
          'type' => 'Add',
          'actor' => tag_manager.uri_for(object.account),
          'target' => a_string_matching(%r{/featured$}),
          'object' => a_hash_including({
            'type' => 'Hashtag',
          }),
        })

        expect(subject).to_not have_key('id')
        expect(subject).to_not have_key('published')
        expect(subject).to_not have_key('to')
        expect(subject).to_not have_key('cc')
      end
    end

    context 'with a collection' do
      let(:object) { Fabricate(:collection) }

      it 'serializes to the expected json' do
        expect(subject).to include({
          'type' => 'Add',
          'actor' => tag_manager.uri_for(object.account),
          'target' => a_string_matching(%r{/featured_collections$}),
          'object' => a_hash_including({
            'type' => 'FeaturedCollection',
          }),
        })

        expect(subject).to_not have_key('id')
        expect(subject).to_not have_key('published')
        expect(subject).to_not have_key('to')
        expect(subject).to_not have_key('cc')
      end
    end
  end
end
