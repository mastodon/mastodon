require 'spec_helper'

describe Chewy::Query::Nodes::HasChild do
  describe '#__render__' do
    def render(&block)
      Chewy::Query::Filters.new(&block).__render__
    end

    specify { expect(render { has_child('child') }).to eq(has_child: {type: 'child'}) }

    specify do
      expect(render { has_child('child').filter(term: {name: 'name'}) })
        .to eq(has_child: {type: 'child', filter: {term: {name: 'name'}}})
    end
    specify do
      expect(render { has_child('child').filter { name == 'name' } })
        .to eq(has_child: {type: 'child', filter: {term: {'name' => 'name'}}})
    end
    specify do
      expect(render { has_child('child').filter(term: {name: 'name'}).filter { age < 42 } })
        .to eq(has_child: {type: 'child', filter: {and: [{term: {name: 'name'}}, range: {'age' => {lt: 42}}]}})
    end
    specify do
      expect(render { has_child('child').filter(term: {name: 'name'}).filter { age < 42 }.filter_mode(:or) })
        .to eq(has_child: {type: 'child', filter: {or: [{term: {name: 'name'}}, range: {'age' => {lt: 42}}]}})
    end

    specify do
      expect(render { has_child('child').query(match: {name: 'name'}) })
        .to eq(has_child: {type: 'child', query: {match: {name: 'name'}}})
    end
    specify do
      expect(render { has_child('child').query(match: {name: 'name'}).query(match: {surname: 'surname'}) })
        .to eq(has_child: {type: 'child', query: {bool: {must: [{match: {name: 'name'}}, {match: {surname: 'surname'}}]}}})
    end
    specify do
      expect(render { has_child('child').query(match: {name: 'name'}).query(match: {surname: 'surname'}).query_mode(:should) })
        .to eq(has_child: {type: 'child', query: {bool: {should: [{match: {name: 'name'}}, {match: {surname: 'surname'}}]}}})
    end

    specify do
      expect(render { has_child('child').filter { name == 'name' }.query(match: {name: 'name'}) })
        .to eq(has_child: {type: 'child', query: {filtered: {query: {match: {name: 'name'}}, filter: {term: {'name' => 'name'}}}}})
    end
    specify do
      expect(render { has_child('child').filter { name == 'name' }.query(match: {name: 'name'}).filter { age < 42 } })
        .to eq(has_child: {type: 'child', query: {filtered: {query: {match: {name: 'name'}}, filter: {and: [{term: {'name' => 'name'}}, range: {'age' => {lt: 42}}]}}}})
    end

    context do
      let(:name) { 'Name' }

      specify do
        expect(render { has_child('child').filter { name == o { name } } })
          .to eq(has_child: {type: 'child', filter: {term: {'name' => 'Name'}}})
      end
    end
  end
end
