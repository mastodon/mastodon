require 'spec_helper'

describe Chewy::Search::Request do
  before { Chewy.massacre }

  before do
    stub_index(:products) do
      define_type :product do
        field :id, type: :integer
        field :name
        field :age, type: :integer
      end
      define_type :city do
        field :id, type: :integer
      end
      define_type :country do
        field :id, type: :integer
      end
    end

    stub_index(:cities) do
      define_type :city
    end
  end

  subject { described_class.new(ProductsIndex) }

  describe '#==' do
    specify { expect(described_class.new(ProductsIndex)).to eq(described_class.new(ProductsIndex)) }
    specify { expect(described_class.new(ProductsIndex)).not_to eq(described_class.new(CitiesIndex)) }
    specify { expect(described_class.new(ProductsIndex)).not_to eq(described_class.new(ProductsIndex, CitiesIndex)) }
    specify { expect(described_class.new(CitiesIndex, ProductsIndex)).to eq(described_class.new(ProductsIndex, CitiesIndex)) }
    specify { expect(described_class.new(ProductsIndex::Product)).to eq(described_class.new(ProductsIndex::Product)) }
    specify { expect(described_class.new(ProductsIndex::Product)).not_to eq(described_class.new(ProductsIndex::City)) }
    specify { expect(described_class.new(ProductsIndex::Product)).not_to eq(described_class.new(ProductsIndex::Product, ProductsIndex::City)) }
    specify { expect(described_class.new(ProductsIndex::City, ProductsIndex::Product)).to eq(described_class.new(ProductsIndex::Product, ProductsIndex::City)) }
    specify { expect(described_class.new(ProductsIndex::City, CitiesIndex::City)).to eq(described_class.new(CitiesIndex::City, ProductsIndex::City)) }

    specify { expect(described_class.new(ProductsIndex).limit(10)).to eq(described_class.new(ProductsIndex).limit(10)) }
    specify { expect(described_class.new(ProductsIndex).limit(10)).not_to eq(described_class.new(ProductsIndex).limit(20)) }

    specify { expect(ProductsIndex.limit(10)).to eq(ProductsIndex.limit(10)) }
    specify { expect(ProductsIndex.limit(10)).not_to eq(CitiesIndex.limit(10)) }
  end

  describe '#render' do
    specify do
      expect(subject.render)
        .to match(
          index: %w[products],
          type: array_including(%w[product city country]),
          body: {}
        )
    end
  end

  describe '#inspect' do
    specify do
      expect(described_class.new(ProductsIndex).inspect)
        .to eq('<Chewy::Search::Request {:index=>["products"], :type=>["product", "city", "country"], :body=>{}}>')
    end
    specify do
      expect(ProductsIndex.limit(10).inspect)
        .to eq('<ProductsIndex::Query {:index=>["products"], :type=>["product", "city", "country"], :body=>{:size=>10}}>')
    end
  end

  %i[query post_filter].each do |name|
    describe "##{name}" do
      specify { expect(subject.send(name, match: {foo: 'bar'}).render[:body]).to include(name => {match: {foo: 'bar'}}) }
      specify { expect(subject.send(name, nil)).to be_a described_class }
      specify { expect(subject.send(name) { match foo: 'bar' }.render[:body]).to include(name => {match: {foo: 'bar'}}) }
      specify do
        expect(subject.send(name, match: {foo: 'bar'}).send(name) { multi_match foo: 'bar' }.render[:body])
          .to include(name => {bool: {must: [{match: {foo: 'bar'}}, {multi_match: {foo: 'bar'}}]}})
      end
      specify { expect { subject.send(name, match: {foo: 'bar'}) }.not_to change { subject.render } }
      specify do
        expect(subject.send(name).should(match: {foo: 'bar'}).send(name).must_not { multi_match foo: 'bar' }.render[:body])
          .to include(name => {bool: {should: {match: {foo: 'bar'}}, must_not: {multi_match: {foo: 'bar'}}}})
      end

      context do
        let(:other_scope) { subject.send(name).should { multi_match foo: 'bar' }.send(name) { match foo: 'bar' } }

        specify do
          expect(subject.send(name).not(other_scope).render[:body])
            .to include(name => {bool: {must_not: {bool: {must: {match: {foo: 'bar'}}, should: {multi_match: {foo: 'bar'}}}}}})
        end
      end
    end
  end

  describe '#filter' do
    specify { expect(subject.filter(match: {foo: 'bar'}).render[:body]).to include(query: {bool: {filter: {match: {foo: 'bar'}}}}) }
    specify { expect(subject.filter(nil)).to be_a described_class }
    specify { expect(subject.filter { match foo: 'bar' }.render[:body]).to include(query: {bool: {filter: {match: {foo: 'bar'}}}}) }
    specify do
      expect(subject.filter(match: {foo: 'bar'}).filter { multi_match foo: 'bar' }.render[:body])
        .to include(query: {bool: {filter: [{match: {foo: 'bar'}}, {multi_match: {foo: 'bar'}}]}})
    end
    specify { expect { subject.filter(match: {foo: 'bar'}) }.not_to change { subject.render } }
    specify do
      expect(subject.filter.should(match: {foo: 'bar'}).filter.must_not { multi_match foo: 'bar' }.render[:body])
        .to include(query: {bool: {filter: {bool: {should: {match: {foo: 'bar'}}, must_not: {multi_match: {foo: 'bar'}}}}}})
    end

    context do
      let(:other_scope) { subject.filter.should { multi_match foo: 'bar' }.filter { match foo: 'bar' } }

      specify do
        expect(subject.filter.not(other_scope).render[:body])
          .to include(query: {bool: {filter: {bool: {must_not: {bool: {must: {match: {foo: 'bar'}}, should: {multi_match: {foo: 'bar'}}}}}}}})
      end
    end
  end

  {limit: :size, offset: :from, terminate_after: :terminate_after}.each do |name, param_name|
    describe "##{name}" do
      specify { expect(subject.send(name, 10).render[:body]).to include(param_name => 10) }
      specify { expect(subject.send(name, 10).send(name, 20).render[:body]).to include(param_name => 20) }
      specify { expect(subject.send(name, 10).send(name, nil).render[:body]).to be_blank }
      specify { expect { subject.send(name, 10) }.not_to change { subject.render } }
    end
  end

  describe '#order' do
    specify { expect(subject.order(:foo).render[:body]).to include(sort: ['foo']) }
    specify { expect(subject.order(foo: 42).order(nil).render[:body]).to include(sort: ['foo' => 42]) }
    specify { expect(subject.order(foo: 42).order(foo: 43).render[:body]).to include(sort: ['foo' => 43]) }
    specify { expect(subject.order(:foo).order(:bar, :baz).render[:body]).to include(sort: %w[foo bar baz]) }
    specify { expect(subject.order(nil).render[:body]).to be_blank }
    specify { expect { subject.order(:foo) }.not_to change { subject.render } }
  end

  describe '#reorder' do
    specify { expect(subject.reorder(:foo).render[:body]).to include(sort: ['foo']) }
    specify { expect(subject.reorder(:foo).reorder(:bar, :baz).render[:body]).to include(sort: %w[bar baz]) }
    specify { expect(subject.reorder(foo: 42).reorder(foo: 43).render[:body]).to include(sort: ['foo' => 43]) }
    specify { expect(subject.reorder(foo: 42).reorder(nil).render[:body]).to be_blank }
    specify { expect(subject.reorder(nil).render[:body]).to be_blank }
    specify { expect { subject.reorder(:foo) }.not_to change { subject.render } }
  end

  %i[track_scores explain version profile].each do |name|
    describe "##{name}" do
      specify { expect(subject.send(name).render[:body]).to include(name => true) }
      specify { expect(subject.send(name).send(name, false).render[:body]).to be_blank }
      specify { expect { subject.send(name) }.not_to change { subject.render } }
    end
  end

  describe '#request_cache' do
    specify { expect(subject.request_cache(true).render[:body]).to include(request_cache: true) }
    specify { expect(subject.request_cache(true).request_cache(false).render[:body]).to include(request_cache: false) }
    specify { expect(subject.request_cache(true).request_cache(nil).render[:body]).to be_blank }
    specify { expect { subject.request_cache(true) }.not_to change { subject.render } }
  end

  %i[search_type preference timeout].each do |name|
    describe "##{name}" do
      specify { expect(subject.send(name, :foo).render[:body]).to include(name => 'foo') }
      specify { expect(subject.send(name, :foo).send(name, :bar).render[:body]).to include(name => 'bar') }
      specify { expect(subject.send(name, :foo).send(name, nil).render[:body]).to be_blank }
      specify { expect { subject.send(name, :foo) }.not_to change { subject.render } }
    end
  end

  describe '#source' do
    specify { expect(subject.source(:foo).render[:body]).to include(_source: ['foo']) }
    specify { expect(subject.source(:foo, :bar).source(nil).render[:body]).to include(_source: %w[foo bar]) }
    specify { expect(subject.source(%i[foo bar]).source(nil).render[:body]).to include(_source: %w[foo bar]) }
    specify { expect(subject.source(excludes: :foo).render[:body]).to include(_source: {excludes: %w[foo]}) }
    specify { expect(subject.source(excludes: :foo).source(excludes: %i[foo bar]).render[:body]).to include(_source: {excludes: %w[foo bar]}) }
    specify { expect(subject.source(excludes: :foo).source(excludes: %i[foo bar]).render[:body]).to include(_source: {excludes: %w[foo bar]}) }
    specify { expect(subject.source(excludes: :foo).source(:bar).render[:body]).to include(_source: {includes: %w[bar], excludes: %w[foo]}) }
    specify { expect(subject.source(excludes: :foo).source(false).render[:body]).to include(_source: false) }
    specify { expect(subject.source(excludes: :foo).source(false).source(excludes: :bar).render[:body]).to include(_source: {excludes: %w[foo bar]}) }
    specify { expect(subject.source(excludes: :foo).source(false).source(true).render[:body]).to include(_source: {excludes: %w[foo]}) }
    specify { expect(subject.source(nil).render[:body]).to be_blank }
    specify { expect { subject.source(:foo) }.not_to change { subject.render } }
  end

  describe '#stored_fields' do
    specify { expect(subject.stored_fields(:foo).render[:body]).to include(stored_fields: ['foo']) }
    specify { expect(subject.stored_fields(%i[foo bar]).stored_fields(nil).render[:body]).to include(stored_fields: %w[foo bar]) }
    specify { expect(subject.stored_fields(:foo).stored_fields(:foo, :bar).render[:body]).to include(stored_fields: %w[foo bar]) }
    specify { expect(subject.stored_fields(:foo).stored_fields(false).render[:body]).to include(stored_fields: '_none_') }
    specify { expect(subject.stored_fields(:foo).stored_fields(false).stored_fields(:bar).render[:body]).to include(stored_fields: %w[foo bar]) }
    specify { expect(subject.stored_fields(:foo).stored_fields(false).stored_fields(true).render[:body]).to include(stored_fields: %w[foo]) }
    specify { expect(subject.stored_fields(nil).render[:body]).to be_blank }
    specify { expect { subject.stored_fields(:foo) }.not_to change { subject.render } }
  end

  %i[script_fields highlight].each do |name|
    describe "##{name}" do
      specify { expect(subject.send(name, foo: {bar: 42}).render[:body]).to include(name => {'foo' => {bar: 42}}) }
      specify { expect(subject.send(name, foo: {bar: 42}).send(name, moo: {baz: 43}).render[:body]).to include(name => {'foo' => {bar: 42}, 'moo' => {baz: 43}}) }
      specify { expect(subject.send(name, foo: {bar: 42}).send(name, nil).render[:body]).to include(name => {'foo' => {bar: 42}}) }
      specify { expect { subject.send(name, foo: {bar: 42}) }.not_to change { subject.render } }
    end
  end

  %i[suggest aggs].each do |name|
    describe "##{name}" do
      specify { expect(subject.send(name, foo: {bar: 42}).render[:body]).to include(name => {'foo' => {bar: 42}}) }
      specify { expect(subject.send(name, foo: {bar: 42}).send(name, moo: {baz: 43}).render[:body]).to include(name => {'foo' => {bar: 42}, 'moo' => {baz: 43}}) }
      specify { expect(subject.send(name, foo: {bar: 42}).send(name, nil).render[:body]).to include(name => {'foo' => {bar: 42}}) }
      specify { expect { subject.send(name, foo: {bar: 42}) }.not_to change { subject.render } }
    end
  end

  describe '#docvalue_fields' do
    specify { expect(subject.docvalue_fields(:foo).render[:body]).to include(docvalue_fields: ['foo']) }
    specify { expect(subject.docvalue_fields(%i[foo bar]).docvalue_fields(nil).render[:body]).to include(docvalue_fields: %w[foo bar]) }
    specify { expect(subject.docvalue_fields(:foo).docvalue_fields(:foo, :bar).render[:body]).to include(docvalue_fields: %w[foo bar]) }
    specify { expect(subject.docvalue_fields(nil).render[:body]).to be_blank }
    specify { expect { subject.docvalue_fields(:foo) }.not_to change { subject.render } }
  end

  describe '#types' do
    specify { expect(subject.types(:product).render[:type]).to contain_exactly('product') }
    specify { expect(subject.types(%i[product city]).types(nil).render[:type]).to match_array(%w[product city]) }
    specify { expect(subject.types(:product).types(:product, :city, :something).render[:type]).to match_array(%w[product city]) }
    specify { expect(subject.types(nil).render[:body]).to be_blank }
    specify { expect { subject.types(:product) }.not_to change { subject.render } }
  end

  describe '#indices_boost' do
    specify { expect(subject.indices_boost(foo: 1.2).render[:body]).to include(indices_boost: [{'foo' => 1.2}]) }
    specify { expect(subject.indices_boost(foo: 1.2).indices_boost(moo: 1.3).render[:body]).to include(indices_boost: [{'foo' => 1.2}, {'moo' => 1.3}]) }
    specify { expect(subject.indices_boost(foo: 1.2).indices_boost(nil).render[:body]).to include(indices_boost: [{'foo' => 1.2}]) }
    specify { expect { subject.indices_boost(foo: 1.2) }.not_to change { subject.render } }
  end

  describe '#rescore' do
    specify { expect(subject.rescore(foo: 42).render[:body]).to include(rescore: [{foo: 42}]) }
    specify { expect(subject.rescore(foo: 42).rescore(moo: 43).render[:body]).to include(rescore: [{foo: 42}, {moo: 43}]) }
    specify { expect(subject.rescore(foo: 42).rescore(nil).render[:body]).to include(rescore: [{foo: 42}]) }
    specify { expect { subject.rescore(foo: 42) }.not_to change { subject.render } }
  end

  describe '#min_score' do
    specify { expect(subject.min_score(1.2).render[:body]).to include(min_score: 1.2) }
    specify { expect(subject.min_score(1.2).min_score(0.5).render[:body]).to include(min_score: 0.5) }
    specify { expect(subject.min_score(1.2).min_score(nil).render[:body]).to be_blank }
    specify { expect { subject.min_score(1.2) }.not_to change { subject.render } }
  end

  describe '#search_after' do
    specify { expect(subject.search_after(:foo, :bar).render[:body]).to include(search_after: %i[foo bar]) }
    specify { expect(subject.search_after(%i[foo bar]).search_after(:baz).render[:body]).to include(search_after: [:baz]) }
    specify { expect(subject.search_after(:foo).search_after(nil).render[:body]).to be_blank }
    specify { expect { subject.search_after(:foo) }.not_to change { subject.render } }
  end

  context 'loading', :orm do
    before do
      stub_model(:city)
      stub_model(:country)

      stub_index(:places) do
        define_type City do
          field :rating, type: 'integer'
        end

        define_type Country do
          field :rating, type: 'integer'
        end
      end
    end

    before { PlacesIndex.import!(cities: cities, countries: countries) }

    let(:cities) { Array.new(2) { |i| City.create!(rating: i) } }
    let(:countries) { Array.new(2) { |i| Country.create!(rating: i + 2) } }

    subject { described_class.new(PlacesIndex).order(:rating) }

    describe '#objects' do
      specify { expect(subject.objects).to eq([*cities, *countries]) }
      specify { expect(subject.objects.class).to eq(Array) }
    end

    describe '#load' do
      specify { expect(subject.load(only: 'city')).to eq([*cities, *countries]) }
      specify { expect(subject.load(only: 'city').map(&:class).uniq).to eq([PlacesIndex::City, PlacesIndex::Country]) }
      specify { expect(subject.load(only: 'city').objects).to eq([*cities, nil, nil]) }
    end
  end

  describe '#merge' do
    let(:first) { described_class.new(ProductsIndex).limit(10).offset(10) }
    let(:second) { described_class.new(ProductsIndex).offset(20).order(:foo) }

    specify { expect(first.merge(second)).to eq(described_class.new(ProductsIndex).limit(10).offset(20).order(:foo)) }
    specify { expect { first.merge(second) }.not_to change { first.render } }
    specify { expect { first.merge(second) }.not_to change { second.render } }

    specify { expect(second.merge(first)).to eq(described_class.new(ProductsIndex).limit(10).offset(10).order(:foo)) }
    specify { expect { second.merge(first) }.not_to change { first.render } }
    specify { expect { second.merge(first) }.not_to change { second.render } }
  end

  context do
    let(:first_scope) { subject.query(foo: 'bar').filter.should(moo: 'baz').post_filter.must_not(boo: 'baf').limit(10) }
    let(:second_scope) { subject.filter(foo: 'bar').post_filter.should(moo: 'baz').query.must_not(boo: 'baf').limit(20) }

    describe '#and' do
      specify do
        expect(first_scope.and(second_scope).render[:body]).to eq(
          query: {bool: {
            must: [{foo: 'bar'}, {bool: {must_not: {boo: 'baf'}}}],
            filter: [{bool: {should: {moo: 'baz'}}}, {foo: 'bar'}]
          }},
          post_filter: {bool: {must: [{bool: {must_not: {boo: 'baf'}}}, {bool: {should: {moo: 'baz'}}}]}},
          size: 10
        )
      end
      specify { expect { first_scope.and(second_scope) }.not_to change { first_scope.render } }
      specify { expect { first_scope.and(second_scope) }.not_to change { second_scope.render } }
    end

    describe '#or' do
      specify do
        expect(first_scope.or(second_scope).render[:body]).to eq(
          query: {bool: {
            should: [{foo: 'bar'}, {bool: {must_not: {boo: 'baf'}}}],
            filter: {bool: {should: [{bool: {should: {moo: 'baz'}}}, {foo: 'bar'}]}}
          }},
          post_filter: {bool: {should: [{bool: {must_not: {boo: 'baf'}}}, {bool: {should: {moo: 'baz'}}}]}},
          size: 10
        )
      end
      specify { expect { first_scope.or(second_scope) }.not_to change { first_scope.render } }
      specify { expect { first_scope.or(second_scope) }.not_to change { second_scope.render } }
    end

    describe '#not' do
      specify do
        expect(first_scope.not(second_scope).render[:body]).to eq(
          query: {bool: {
            must: {foo: 'bar'}, must_not: {bool: {must_not: {boo: 'baf'}}},
            filter: {bool: {should: {moo: 'baz'}, must_not: {foo: 'bar'}}}
          }},
          post_filter: {bool: {must_not: [{boo: 'baf'}, {bool: {should: {moo: 'baz'}}}]}},
          size: 10
        )
      end
      specify { expect { first_scope.not(second_scope) }.not_to change { first_scope.render } }
      specify { expect { first_scope.not(second_scope) }.not_to change { second_scope.render } }
    end
  end

  describe '#only' do
    subject { described_class.new(ProductsIndex).limit(10).offset(10) }

    specify { expect(subject.only(:limit)).to eq(described_class.new(ProductsIndex).limit(10)) }
    specify { expect { subject.only(:limit) }.not_to change { subject.render } }
  end

  describe '#except' do
    subject { described_class.new(ProductsIndex).limit(10).offset(10) }

    specify { expect(subject.except(:limit)).to eq(described_class.new(ProductsIndex).offset(10)) }
    specify { expect { subject.except(:limit) }.not_to change { subject.render } }
  end

  context 'index does not exist' do
    specify { expect(subject).to eq([]) }
    specify { expect(subject.count).to eq(0) }
  end

  context 'integration' do
    let(:products) { Array.new(3) { |i| {id: i.next.to_i, name: "Name#{i.next}", age: 10 * i.next}.stringify_keys! } }
    let(:cities) { Array.new(3) { |i| {id: (i.next + 3).to_i}.stringify_keys! } }
    let(:countries) { Array.new(3) { |i| {id: (i.next + 6).to_i}.stringify_keys! } }
    before do
      ProductsIndex::Product.import!(products.map { |h| double(h) })
      ProductsIndex::City.import!(cities.map { |h| double(h) })
      ProductsIndex::Country.import!(countries.map { |h| double(h) })
      CitiesIndex::City.import!(cities.map { |h| double(h) })
    end

    specify { expect(subject[0]._data).to be_a Hash }

    context 'another index' do
      subject { described_class.new(CitiesIndex) }

      specify { expect(subject.count).to eq(3) }
      specify { expect(subject.size).to eq(3) }
    end

    context 'limited types' do
      subject { described_class.new(ProductsIndex::City, ProductsIndex::Country) }

      specify { expect(subject.count).to eq(6) }
      specify { expect(subject.size).to eq(6) }
    end

    context 'mixed types' do
      subject { described_class.new(CitiesIndex, ProductsIndex::Product) }

      specify { expect(subject.count).to eq(9) }
      specify { expect(subject.size).to eq(9) }
    end

    context 'instrumentation' do
      specify do
        outer_payload = nil
        ActiveSupport::Notifications.subscribe('search_query.chewy') do |_name, _start, _finish, _id, payload|
          outer_payload = payload
        end
        subject.query(match: {name: 'name3'}).to_a
        expect(outer_payload).to eq(
          index: ProductsIndex,
          indexes: [ProductsIndex],
          request: {index: ['products'], type: %w[product city country], body: {query: {match: {name: 'name3'}}}},
          type: [ProductsIndex::Product, ProductsIndex::City, ProductsIndex::Country],
          types: [ProductsIndex::Product, ProductsIndex::City, ProductsIndex::Country]
        )
      end
    end

    describe '#none' do
      specify { expect(subject.none).to eq([]) }
    end

    describe '#highlight' do
      specify { expect(subject.query(match: {name: 'name3'}).highlight(fields: {name: {}}).first.name).to eq('Name3') }
      specify { expect(subject.query(match: {name: 'name3'}).highlight(fields: {name: {}}).first.name_highlight).to eq('<em>Name3</em>') }
      specify { expect(subject.query(match: {name: 'name3'}).highlight(fields: {name: {}}).first._data['_source']['name']).to eq('Name3') }
    end

    describe '#suggest' do
      specify do
        expect(subject.suggest(
          foo: {
            text: 'name',
            term: {field: 'name'}
          }
        ).suggest).to eq(
          'foo' => [
            {'text' => 'name', 'offset' => 0, 'length' => 4, 'options' => [
              {'text' => 'name1', 'score' => 0.75, 'freq' => 1},
              {'text' => 'name2', 'score' => 0.75, 'freq' => 1},
              {'text' => 'name3', 'score' => 0.75, 'freq' => 1}
            ]}
          ]
        )
      end
    end

    describe '#aggs' do
      specify do
        expect(subject.aggs(avg_age: {avg: {field: :age}}).aggs)
          .to eq('avg_age' => {'value' => 20.0})
      end
    end

    describe '#size' do
      specify { expect(subject.size).to eq(9) }
      specify { expect(subject.limit(6).size).to eq(6) }
      specify { expect(subject.offset(6).size).to eq(3) }
    end

    describe '#total' do
      specify { expect(subject.limit(6).total).to eq(9) }
      specify { expect(subject.limit(6).total_count).to eq(9) }
      specify { expect(subject.offset(6).total_entries).to eq(9) }
    end

    describe '#count' do
      specify { expect(subject.count).to eq(9) }
      specify { expect(subject.limit(6).count).to eq(9) }
      specify { expect(subject.offset(6).count).to eq(9) }
      specify { expect(subject.types(:product, :something).count).to eq(3) }
      specify { expect(subject.types(:product, :country).count).to eq(6) }
      specify { expect(subject.filter(term: {age: 10}).count).to eq(1) }
      specify { expect(subject.query(term: {age: 10}).count).to eq(1) }
      specify { expect(subject.order(nil).count).to eq(9) }
      specify { expect(subject.none.count).to eq(0) }

      context do
        before { expect(Chewy.client).to receive(:count).and_call_original }
        specify { subject.count }
      end

      context do
        subject { described_class.new(ProductsIndex).limit(6) }
        before do
          expect(Chewy.client).not_to receive(:count)
          subject.total
        end
        specify { expect(subject.count).to eq(9) }
      end
    end

    describe '#exists?' do
      before { expect(Chewy.client).to receive(:search).once.and_call_original }

      specify { expect(subject.exists?).to be(true) }
      specify { expect(subject.filter(match: {name: 'foo'}).exist?).to be(false) }

      context do
        before { subject.total }
        specify { expect(subject.exists?).to eq(true) }
      end
    end

    describe '#first' do
      subject { described_class.new(ProductsIndex).order(id: {order: 'desc'}) }

      context do
        before { expect(Chewy.client).to receive(:search).once.and_call_original }

        specify { expect(subject.first).to be_a(ProductsIndex::Country).and have_attributes(id: 9) }
        specify { expect(subject.first(3).map(&:id)).to eq([9, 8, 7]) }
        specify { expect(subject.first(10).map(&:id)).to have(9).items }
        specify { expect(subject.limit(5).first(10).map(&:id)).to have(9).items }
        specify { expect(subject.terminate_after(5).first(10).map(&:id)).to have(5).items }
      end

      context do
        before do
          subject.response
          expect(Chewy.client).not_to receive(:search)
        end

        specify { expect(subject.first).to be_a(ProductsIndex::Country).and have_attributes(id: 9) }
        specify { expect(subject.first(3).map(&:id)).to eq([9, 8, 7]) }
        specify { expect(subject.first(10).map(&:id)).to have(9).items }

        context do
          subject { described_class.new(ProductsIndex).terminate_after(5) }
          specify { expect(subject.first(10).map(&:id)).to have(5).items }
        end
      end

      context do
        subject { described_class.new(ProductsIndex).limit(5) }
        before do
          subject.response
          expect(Chewy.client).to receive(:search).once.and_call_original
        end
        specify { expect(subject.first(10).map(&:id)).to have(9).items }
      end
    end

    describe '#find' do
      specify { expect(subject.find('1')).to be_a(ProductsIndex::Product).and have_attributes(id: 1) }
      specify { expect(subject.find { |w| w.id == 2 }).to be_a(ProductsIndex::Product).and have_attributes(id: 2) }
      specify { expect(subject.limit(2).find('1', '3', '7').map(&:id)).to contain_exactly(1, 3, 7) }
      specify { expect(subject.find(1, 3, 7).map(&:id)).to contain_exactly(1, 3, 7) }
      specify { expect { subject.find('1', '3', '42') }.to raise_error Chewy::DocumentNotFound, 'Could not find documents for ids: 42' }
      specify { expect { subject.find(1, 3, 42) }.to raise_error Chewy::DocumentNotFound, 'Could not find documents for ids: 42' }
      specify { expect { subject.query(match: {name: 'name3'}).find('1', '3') }.to raise_error Chewy::DocumentNotFound, 'Could not find documents for ids: 1' }
      specify { expect { subject.query(match: {name: 'name2'}).find('1', '3') }.to raise_error Chewy::DocumentNotFound, 'Could not find documents for ids: 1 and 3' }
      specify { expect { subject.filter(match: {name: 'name2'}).find('1', '3') }.to raise_error Chewy::DocumentNotFound, 'Could not find documents for ids: 1 and 3' }
      specify { expect { subject.post_filter(match: {name: 'name2'}).find('1', '3') }.to raise_error Chewy::DocumentNotFound, 'Could not find documents for ids: 1 and 3' }

      context 'make sure it returns everything' do
        let(:countries) { Array.new(6) { |i| {id: (i.next + 6).to_i}.stringify_keys! } }
        before { expect(Chewy.client).not_to receive(:scroll) }

        specify { expect(subject.find((1..12).to_a)).to have(12).items }
      end

      context 'make sure it returns everything in batches if needed' do
        before { stub_const("#{described_class}::DEFAULT_BATCH_SIZE", 5) }
        before { expect(Chewy.client).to receive(:scroll).once.and_call_original }

        specify { expect(subject.find((1..9).to_a)).to have(9).items }
        specify { expect(subject.find((1..9).to_a)).to all be_a(Chewy::Type) }
      end
    end

    describe '#pluck' do
      specify { expect(subject.limit(5).pluck(:_id)).to eq(%w[1 2 3 4 5]) }
      specify { expect(subject.limit(5).pluck(:_id, :age)).to eq([['1', 10], ['2', 20], ['3', 30], ['4', nil], ['5', nil]]) }
      specify { expect(subject.limit(5).source(:name).pluck(:id, :age)).to eq([[1, 10], [2, 20], [3, 30], [4, nil], [5, nil]]) }
      specify do
        expect(subject.limit(5).pluck(:_index, :_type, :name)).to eq([
          %w[products product Name1],
          %w[products product Name2],
          %w[products product Name3],
          ['products', 'city', nil],
          ['products', 'city', nil]
        ])
      end

      context 'make sure it returns everything in batches if needed' do
        before { stub_const("#{described_class}::DEFAULT_PLUCK_BATCH_SIZE", 5) }
        before { expect(Chewy.client).to receive(:scroll).once.and_call_original }

        specify { expect(subject.pluck(:_id)).to eq((1..9).to_a.map(&:to_s)) }
      end
    end

    describe '#delete_all' do
      specify do
        expect do
          subject.none.delete_all
          Chewy.client.indices.refresh(index: 'products')
        end.not_to change { described_class.new(ProductsIndex).total }.from(9)
      end
      specify do
        expect do
          subject.query(match: {name: 'name3'}).delete_all
          Chewy.client.indices.refresh(index: 'products')
        end.to change { described_class.new(ProductsIndex).total }.from(9).to(8)
      end
      specify do
        expect do
          subject.filter(range: {age: {gte: 10, lte: 20}}).delete_all
          Chewy.client.indices.refresh(index: 'products')
        end.to change { described_class.new(ProductsIndex).total_count }.from(9).to(7)
      end
      specify do
        expect do
          subject.types(:product).delete_all
          Chewy.client.indices.refresh(index: 'products')
        end.to change { described_class.new(ProductsIndex::Product).total_entries }.from(3).to(0)
      end
      specify do
        expect do
          subject.delete_all
          Chewy.client.indices.refresh(index: 'products')
        end.to change { described_class.new(ProductsIndex).total }.from(9).to(0)
      end
      specify do
        expect do
          described_class.new(ProductsIndex::City).delete_all
          Chewy.client.indices.refresh(index: 'products')
        end.to change { described_class.new(ProductsIndex).total }.from(9).to(6)
      end

      specify do
        outer_payload = nil
        ActiveSupport::Notifications.subscribe('delete_query.chewy') do |_name, _start, _finish, _id, payload|
          outer_payload = payload
        end
        subject.query(match: {name: 'name3'}).delete_all
        expect(outer_payload).to eq(
          index: ProductsIndex,
          indexes: [ProductsIndex],
          request: {index: ['products'], type: %w[product city country], body: {query: {match: {name: 'name3'}}}, refresh: true},
          type: [ProductsIndex::Product, ProductsIndex::City, ProductsIndex::Country],
          types: [ProductsIndex::Product, ProductsIndex::City, ProductsIndex::Country]
        )
      end

      specify do
        outer_payload = nil
        ActiveSupport::Notifications.subscribe('delete_query.chewy') do |_name, _start, _finish, _id, payload|
          outer_payload = payload
        end
        subject.query(match: {name: 'name3'}).delete_all(refresh: false)
        expect(outer_payload).to eq(
          index: ProductsIndex,
          indexes: [ProductsIndex],
          request: {index: ['products'], type: %w[product city country], body: {query: {match: {name: 'name3'}}}, refresh: false},
          type: [ProductsIndex::Product, ProductsIndex::City, ProductsIndex::Country],
          types: [ProductsIndex::Product, ProductsIndex::City, ProductsIndex::Country]
        )
      end
    end
  end
end
