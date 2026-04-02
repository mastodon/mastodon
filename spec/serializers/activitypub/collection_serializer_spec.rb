# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::CollectionSerializer do
  describe '.serializer_for' do
    subject { described_class.serializer_for(model, {}) }

    context 'with a Status model' do
      let(:model) { Status.new }

      it { is_expected.to eq(ActivityPub::NoteSerializer) }
    end

    context 'with a FeaturedTag model' do
      let(:model) { FeaturedTag.new }

      it { is_expected.to eq(ActivityPub::HashtagSerializer) }
    end

    context 'with an ActivityPub::CollectionPresenter' do
      let(:model) { ActivityPub::CollectionPresenter.new }

      it { is_expected.to eq(described_class) }
    end

    context 'with a String' do
      let(:model) { '' }

      it { is_expected.to eq(described_class::StringSerializer) }
    end

    context 'with an Array' do
      let(:model) { [] }

      it { is_expected.to eq(ActiveModel::Serializer::CollectionSerializer) }
    end

    context 'with a Collection' do
      let(:model) { Collection.new }

      it { is_expected.to eq(ActivityPub::FeaturedCollectionSerializer) }
    end
  end
end
