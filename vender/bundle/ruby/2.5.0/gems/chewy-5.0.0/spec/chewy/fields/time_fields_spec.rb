require 'spec_helper'

describe 'Time fields' do
  before { Chewy.massacre }

  before do
    stub_index(:posts) do
      define_type :post do
        field :published_at, type: 'date'
      end
    end
  end

  before do
    PostsIndex::Post.import(
      double(published_at: ActiveSupport::TimeZone[-28_800].parse('2014/12/18 19:00')),
      double(published_at: ActiveSupport::TimeZone[-21_600].parse('2014/12/18 20:00')),
      double(published_at: ActiveSupport::TimeZone[-21_600].parse('2014/12/17 20:00'))
    )
  end

  let(:time) { ActiveSupport::TimeZone[-14_400].parse('2014/12/18 22:00') }
  let(:range) { (time - 1.minute)..(time + 1.minute) }

  specify { expect(PostsIndex.total).to eq(3) }
  specify { expect(PostsIndex.filter(range: {published_at: {gte: range.min, lte: range.max}}).size).to eq(1) }
  specify { expect(PostsIndex.filter(range: {published_at: {gt: range.min.utc, lt: (range.max + 1.hour).utc}}).size).to eq(2) }
end
